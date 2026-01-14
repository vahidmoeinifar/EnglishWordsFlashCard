#ifndef DB_H
#define DB_H

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlApplicationEngine>

class Word : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString word READ word WRITE setWord NOTIFY wordChanged)
    Q_PROPERTY(QString type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QString definition READ definition WRITE setDefinition NOTIFY definitionChanged)

public:
    explicit Word(QObject *parent = nullptr);
    static Word* create(QQmlEngine *qmlEngine, QJSEngine *jsEngine);

    Q_INVOKABLE void sendRandomRecord();
    Q_INVOKABLE bool openDatabase(const QString &dbPath);
    Q_INVOKABLE int getTotalWords();

    const QString &word() const;
    void setWord(const QString &newWord);

    const QString &type() const;
    void setType(const QString &newType);

    const QString &definition() const;
    void setDefinition(const QString &newDefinition);

signals:
    void wordChanged();
    void typeChanged();
    void definitionChanged();
    void databaseOpened(bool success);
    void errorOccurred(const QString &error);

private:
    QString m_word;
    QString m_type;
    QString m_definition;
    QSqlDatabase m_database;
};

#endif // DB_H
