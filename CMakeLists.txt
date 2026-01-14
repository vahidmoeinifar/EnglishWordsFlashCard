cmake_minimum_required(VERSION 3.16)

project(EnglishWordsFlashCard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt6 6.2 COMPONENTS Quick Sql REQUIRED)

qt_add_executable(appEnglishWordsFlashCard
    main.cpp
    db.cpp
    db.h
)

qt_add_qml_module(appEnglishWordsFlashCard
    URI EnglishWordsFlashCard
    VERSION 1.0
    QML_FILES main.qml
)

# Create a resources.qrc file with your database
set(RESOURCE_FILES
    main.qml
    dictionary.db
)

qt_add_resources(appEnglishWordsFlashCard "app_resources"
    PREFIX "/"
    FILES ${RESOURCE_FILES}
)

# Add database file to resources explicitly
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/dictionary.db")
    set(RESOURCE_FILES ${RESOURCE_FILES} dictionary.db)
endif()

# For iOS/macOS
set_target_properties(appEnglishWordsFlashCard PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appEnglishWordsFlashCard
    PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::Qml
)

# Copy database file to build directory (for development)
add_custom_command(TARGET appEnglishWordsFlashCard POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CMAKE_CURRENT_SOURCE_DIR}/dictionary.db"
    "$<TARGET_FILE_DIR:appEnglishWordsFlashCard>/"
)

include(GNUInstallDirs)
install(TARGETS appEnglishWordsFlashCard
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
