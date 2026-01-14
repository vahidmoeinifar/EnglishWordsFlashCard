#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "db.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);



     qmlRegisterType<Word>("backend", 1, 0, "WordDB");

    QQmlApplicationEngine engine;

    // Alternative: If singleton registration doesn't work, create instance and set as context property
    // Word *wordDB = new Word(&app);
    // engine.rootContext()->setContextProperty("wordDB", wordDB);

    const QUrl url(u"qrc:/EnglishWordsFlashCard/main.qml"_qs);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
