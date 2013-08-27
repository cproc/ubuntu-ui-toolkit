/*
 * Copyright 2012 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import "ListItems" as ListItem
import Ubuntu.Components 0.1 as Components

ListItem.Standard {
    id: option

    property string text
    property string subText
    property url icon
    property ListView listView: ListView.view
    property color assetColour: listView.container.themeColour
    property bool colourImage: listView.container.colourImage
    property string fragColourShader:
        "varying highp vec2 qt_TexCoord0;
         uniform sampler2D source;
         uniform lowp vec4 colour;
         uniform lowp float qt_Opacity;

         void main() {
            lowp vec4 sourceColour = texture2D(source, qt_TexCoord0);
            gl_FragColor = colour * sourceColour.a * qt_Opacity;
        }"

    width: parent.width + units.gu(2)
    showDivider: index !== listView.count - 1 ? 1 : 0
    highlightWhenPressed: false
    selected: ListView.isCurrentItem
    anchors {
        left: parent.left
        leftMargin: units.gu(-2)
    }
    onClicked: {
        if (listView.container.isExpanded) {
            listView.previousIndex = listView.currentIndex;
            listView.currentIndex = index;
        }

        if (!listView.expanded) {
            listView.container.isExpanded = !listView.container.isExpanded;
        }
    }

    Component.onCompleted: {
        height = listView.itemHeight = childrenRect.height;
    }

    //Since we don't want to add states to our divider, we use the exposed alias provided in Empty to access it and alter it's opacity from here.
    states: [ State {
            name: "dividerExpanded"
            when: listView.container.state === "expanded" && index === listView.currentIndex
            PropertyChanges {
                target: option.divider
                opacity: 1
            }
        }, State {
            name: "dividerCollapsed"
            when: listView.container.state === "collapsed" && index === listView.currentIndex
            PropertyChanges {
                target: option.divider
                opacity: 0
            }
        }
    ]

    //As with our states, we apply the transition with our divider as the target.
    transitions: [ Transition {
            from: "dividerExpanded"
            to: "dividerCollapsed"
            UbuntuNumberAnimation {
                target: option.divider
                properties: "opacity"
                duration: Components.UbuntuAnimation.SlowDuration
            }
        }
    ]

    resources: [
        Connections {
            target: listView.container
            onIsExpandedChanged: {
                optionExpansion.stop();
                imageExpansion.stop();
                optionCollapse.stop();
                selectedImageCollapse.stop();
                deselectedImageCollapse.stop();

                if (listView.container.isExpanded === true) {
                    if (!option.selected) {
                        optionExpansion.start();

                        //Ensure a source change. This solves a bug which happens occasionaly when source is switched correctly. Probably related to the image.source binding.
                        image.source = listView.container.tick
                    } else {
                        imageExpansion.start();
                    }
                } else {
                    if (!option.selected) {
                        optionCollapse.start();
                    } else {
                        if (listView.previousIndex !== listView.currentIndex)
                            selectedImageCollapse.start();
                        else {
                            deselectedImageCollapse.start();
                        }
                    }
                }
            }
        }, SequentialAnimation {
            id: imageExpansion

            PropertyAnimation {
                target: image
                properties: "opacity"
                from : 1.0
                to: 0.0
                duration: Components.UbuntuAnimation.FastDuration
            }
            PauseAnimation { duration: Components.UbuntuAnimation.BriskDuration - Components.UbuntuAnimation.FastDuration }
            PropertyAction {
                target: image
                property: "source"
                value: listView.container.tick
            }
            PropertyAnimation {
                target: image
                properties: "opacity"
                from : 0.0
                to: 1.0
                duration: Components.UbuntuAnimation.FastDuration
            }
        }, PropertyAnimation {
            id: optionExpansion

            target: option
            properties: "opacity"
            from : 0.0
            to: 1.0
            duration: Components.UbuntuAnimation.SlowDuration
        }, SequentialAnimation {
            id: deselectedImageCollapse

            PauseAnimation { duration: Components.UbuntuAnimation.BriskDuration }
            PropertyAnimation {
                target: image
                properties: "opacity"
                from : 1.0
                to: 0.0
                duration: Components.UbuntuAnimation.FastDuration
            }
            PauseAnimation { duration: Components.UbuntuAnimation.FastDuration }
            PropertyAction {
                target: image
                property: "source"
                value: listView.container.chevron
            }
            PropertyAnimation {
                target: image
                properties: "opacity"
                from : 0.0
                to: 1.0
                duration: Components.UbuntuAnimation.FastDuration
            }
        }, SequentialAnimation {
            id: selectedImageCollapse

            PropertyAnimation {
                target: image
                properties: "opacity"
                from : 0.0
                to: 1.0
                duration: Components.UbuntuAnimation.FastDuration
            }
            PauseAnimation { duration: Components.UbuntuAnimation.BriskDuration - Components.UbuntuAnimation.FastDuration }
            PropertyAnimation {
                target: image
                properties: "opacity"
                from : 1.0
                to: 0.0
                duration: Components.UbuntuAnimation.FastDuration
            }
            PauseAnimation { duration: Components.UbuntuAnimation.FastDuration }
            PropertyAction {
                target: image
                property: "source"
                value: listView.container.chevron
            }
            PropertyAnimation {
                target: image
                properties: "opacity"
                from : 0.0
                to: 1.0
                duration: Components.UbuntuAnimation.FastDuration
            }
        }, PropertyAnimation {
                id: optionCollapse
                target: option
                properties: "opacity"
                from : 1.0
                to: 0.0
                duration: Components.UbuntuAnimation.SlowDuration
        }
    ]

    Row {
        spacing: units.gu(1)

        anchors {
            left: parent.left
            leftMargin: units.gu(3)
            verticalCenter: parent.verticalCenter
        }

        Image {
            id: leftIcon

            source: icon

            ShaderEffect {
                property color colour: assetColour
                property Image source: parent

                width: source.width
                height: source.height
                visible: colourImage

                fragmentShader: fragColourShader
             }
        }

        Column {
            anchors {
                verticalCenter: parent.verticalCenter
            }
            Label {
                text: option.text === "" ? modelData : option.text
            }
            Label {
                text: option.subText
                visible: option.subText !== "" ? true : false
                fontSize: "small"
            }
        }
    }

    Image {
        id: image

        width: units.gu(2)
        height: units.gu(2)
        source: listView.expanded ? listView.container.tick : listView.container.chevron
        opacity: option.selected ? 1.0 : 0.0
        anchors {
            right: parent.right
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }

        //Our behaviour is only enabled for our expanded list due to flickering bugs in relation to all this other animations running on the expanding version.
        Behavior on opacity {
            enabled: listView.expanded

            UbuntuNumberAnimation {
                properties: "opacity"
                duration: Components.UbuntuAnimation.FastDuration
            }
        }

        ShaderEffect {
            property color colour: assetColour
            property Image source: parent

            width: source.width
            height: source.height

            fragmentShader: fragColourShader
         }
    }
}