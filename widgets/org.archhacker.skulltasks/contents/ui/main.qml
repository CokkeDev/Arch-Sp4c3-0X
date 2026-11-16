import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    property color cActive:   "#B8860B"  // dorado oscuro: la ventana enfocada
    property color cVisible:  "#39FF14"  // verde: en uso (visible, no enfocada)
    property color cInactive: "#FF2A2A"  // rojo: no ocupada (minimizada/oculta)

    TaskManager.TasksModel {
        id: tasksModel
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortManual
        filterByScreen: false
        filterByVirtualDesktop: false
        filterByActivity: false
        filterNotMaximized: false
    }

    preferredRepresentation: fullRepresentation

    fullRepresentation: RowLayout {
        id: row
        spacing: 5
        Layout.minimumWidth: 28
        Layout.minimumHeight: 26

        Repeater {
            model: tasksModel

            delegate: Item {
                id: del
                width: 22
                height: 22
                Layout.alignment: Qt.AlignVCenter

                property color stateColor: model.IsActive ? root.cActive
                    : (model.IsMinimized || model.IsHidden) ? root.cInactive
                    : root.cVisible

                SkullIcon {
                    anchors.centerIn: parent
                    width: 20
                    height: 20
                    color: del.stateColor
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: tasksModel.requestActivate(tasksModel.makeModelIndex(index))
                    QQC2.ToolTip.visible: containsMouse
                    QQC2.ToolTip.text: (model.AppName ? model.AppName : "Ventana")
                        + (model.IsActive ? "  (enfocada)"
                           : (model.IsMinimized ? "  (minimizada)" : "  (en uso)"))
                }
            }
        }

        // marcador cuando no hay ventanas
        QQC2.Label {
            visible: tasksModel.count === 0
            text: "·"
            color: root.cInactive
            font.pixelSize: 18
        }
    }
}
