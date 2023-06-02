// SPDX-License-Identifier: GPL-2.0-or-later
// SPDX-FileCopyrightText: 2023 Denys Madureira <denysmb@zoho.com>

import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.YTSongDownloader 1.0
import org.kde.kirigami 2.19 as Kirigami

Kirigami.ApplicationWindow {
    id: root

    function getFormat() {
        return audioFormat.currentText.toLowerCase();
    }

    function getFileNameWithPath() {
        const finalPath = path.text ? path.text : "~";
        return fileName.text ? `${finalPath}/${fileName.text}.%(ext)s` : `${finalPath}/%(title)s.%(ext)s`;
    }

    function getCommandLine() {
        return `yt-dlp --extract-audio --audio-format ${getFormat()} ${url.text} -o "${getFileNameWithPath()}"`;
    }

    function isValidUrl() {
        return url.text.startsWith("https://www.youtube.com/watch?v=");
    }

    title: i18n("YTSongDownloader")
    minimumWidth: Kirigami.Units.gridUnit * 20
    minimumHeight: Kirigami.Units.gridUnit * 20
    onClosing: App.saveWindowGeometry(root)
    onWidthChanged: saveWindowGeometryTimer.restart()
    onHeightChanged: saveWindowGeometryTimer.restart()
    onXChanged: saveWindowGeometryTimer.restart()
    onYChanged: saveWindowGeometryTimer.restart()
    Component.onCompleted: App.restoreWindowGeometry(root)
    pageStack.initialPage: page

    // This timer allows to batch update the window size change to reduce
    // the io load and also work around the fact that x/y/width/height are
    // changed when loading the page and overwrite the saved geometry from
    // the previous session.
    Timer {
        id: saveWindowGeometryTimer

        interval: 1000
        onTriggered: App.saveWindowGeometry(root)
    }

    Timer {
        id: delayRequestTimer

        interval: 100
        onTriggered: App.request(progressBar, getCommandLine())
    }

    Kirigami.Page {
        id: page

        Layout.fillWidth: true
        title: i18n("YT Song Downloader")

        Kirigami.FormLayout {
            anchors.fill: parent

            Item {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "Input information"
            }

            Controls.TextField {
                id: url

                Kirigami.FormData.label: "Youtube URL:"
                placeholderText: "https://www.youtube.com/watch?v=..."
            }

            Item {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "Output information"
            }

            Controls.ComboBox {
                id: audioFormat

                Kirigami.FormData.label: "Audio format:"
                model: ["MP3", "M4A", "WAV", "AAC", "ALAC", "FLAC", "OPUS", "VORBIS"]
            }

            Controls.TextField {
                id: path

                Kirigami.FormData.label: "Save folder:"
                placeholderText: "~/Music"
            }

            Controls.TextField {
                id: fileName

                Kirigami.FormData.label: "Save file name (optional):"
                placeholderText: "Artist - Song Name"
            }

            Item {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "Status"
            }

            Controls.ProgressBar {
                id: progressBar

                Kirigami.FormData.label: "Download:"
                indeterminate: false
            }

        }

        actions.main: Kirigami.Action {
            text: i18n("Download")
            icon.name: "download"
            tooltip: i18n("Download YouTube song")
            onTriggered: {
                progressBar.indeterminate = true;
                delayRequestTimer.start();
            }
            enabled: isValidUrl()
        }

    }

    globalDrawer: Kirigami.GlobalDrawer {
        title: i18n("YTSongDownloader")
        titleIcon: "applications-graphics"
        isMenu: !root.isMobile
        actions: [
            Kirigami.Action {
                text: i18n("About YTSongDownloader")
                icon.name: "help-about"
                onTriggered: pageStack.layers.push('qrc:About.qml')
            },
            Kirigami.Action {
                text: i18n("Quit")
                icon.name: "application-exit"
                onTriggered: Qt.quit()
            }
        ]
    }

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }

}
