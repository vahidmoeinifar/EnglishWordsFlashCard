#include "db.h"
#include <QCoreApplication>
#include <QDir>
#include <QJSEngine>
#include <QQmlEngine>
#include <QRandomGenerator>
#include <QStandardPaths>
#include <QFile>

Word::Word(QObject *parent) : QObject(parent)
{
    m_word = "Loading...";
    m_type = "";
    m_definition = "Click to load a word";

    // Auto-open database in application directory
    QString dbPath = QCoreApplication::applicationDirPath() + "/dictionary.db";

    // For development, also check qrc resources
    QString qrcPath = ":/dictionary.db";
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/dictionary.db";

    // Try multiple locations
    if (QFile::exists(dbPath)) {
        openDatabase(dbPath);
    } else if (QFile::exists(qrcPath)) {
        // Copy from resources to app data location
        QFile::copy(qrcPath, appDataPath);
        openDatabase(appDataPath);
    } else {
        emit errorOccurred("Database file not found");
    }
}

Word* Word::create(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    Q_UNUSED(qmlEngine)
    Q_UNUSED(jsEngine)

    Word *instance = new Word();
    return instance;
}

bool Word::openDatabase(const QString &dbPath)
{
    // Remove existing connection if any
    if (m_database.isOpen()) {
        QString connectionName = m_database.connectionName();
        m_database.close();
        if (!connectionName.isEmpty()) {
            QSqlDatabase::removeDatabase(connectionName);
        }
    }

    // Generate unique connection name using Qt6 method
    QString connectionName = QString("flashcard_connection_%1")
                                 .arg(QRandomGenerator::global()->bounded(1000000));

    m_database = QSqlDatabase::addDatabase("QSQLITE", connectionName);
    m_database.setDatabaseName(dbPath);

    if (!m_database.open()) {
        qWarning() << "Cannot open database:" << m_database.lastError().text();
        emit errorOccurred(m_database.lastError().text());
        emit databaseOpened(false);
        return false;
    }

    // Check if table exists
    QSqlQuery query(m_database);
    if (!query.exec("SELECT name FROM sqlite_master WHERE type='table' AND name='entries'")) {
        qWarning() << "Table check failed:" << query.lastError().text();
        emit databaseOpened(false);
        return false;
    }

    if (!query.next()) {
        qWarning() << "Table 'entries' not found in database";
        emit errorOccurred("Database table 'entries' not found");
        emit databaseOpened(false);
        return false;
    }

    qDebug() << "Database opened successfully from:" << dbPath;
    emit databaseOpened(true);
    return true;
}
// Rest of the implementation remains the same...
int Word::getTotalWords()
{
    if (!m_database.isOpen()) {
        return 0;
    }

    QSqlQuery query(m_database);
    if (query.exec("SELECT COUNT(*) FROM entries")) {
        if (query.next()) {
            return query.value(0).toInt();
        }
    }
    return 0;
}

void Word::sendRandomRecord()
{
    if (!m_database.isOpen()) {
        setWord("Database Error");
        setDefinition("Please ensure dictionary.db is in the application folder");
        emit errorOccurred("Database not opened");
        return;
    }

    QSqlQuery query(m_database);
    query.prepare("SELECT word, wordtype, definition FROM entries ORDER BY RANDOM() LIMIT 1");

    if (!query.exec()) {
        qWarning() << "Query failed:" << query.lastError().text();
        setWord("Query Error");
        setDefinition("Failed to fetch word from database");
        emit errorOccurred(query.lastError().text());
        return;
    }

    if (query.next()) {
        setWord(query.value("word").toString());
        setType(query.value("wordtype").toString());
        setDefinition(query.value("definition").toString());
    } else {
        setWord("No Data");
        setType("");
        setDefinition("The dictionary is empty");
    }
}

const QString &Word::word() const { return m_word; }
const QString &Word::type() const { return m_type; }
const QString &Word::definition() const { return m_definition; }

void Word::setWord(const QString &newWord)
{
    if (m_word == newWord) return;
    m_word = newWord;
    emit wordChanged();
}

void Word::setType(const QString &newType)
{
    if (m_type == newType) return;
    m_type = newType;
    emit typeChanged();
}

void Word::setDefinition(const QString &newDefinition)
{
    if (m_definition == newDefinition) return;
    m_definition = newDefinition;
    emit definitionChanged();
}
