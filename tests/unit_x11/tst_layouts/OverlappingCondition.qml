/*
 * Copyright 2013 Canonical Ltd.
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
import Ubuntu.Components 0.1
import Ubuntu.Layouts 0.1

Item {
    id: root
    width: units.gu(40)
    height: units.gu(30)

    Layouts {
        objectName: "layouts"
        id: layouts
        anchors.fill: parent
        layouts: [
            ConditionalLayout {
                name: "small"
                when: layouts.width <= units.gu(40)
                Column {
                    anchors.fill: parent
                    ItemLayout {
                        item: "item1"
                    }
                    ItemLayout {
                        item: "item2"
                    }
                    ItemLayout {
                        item: "item3"
                    }
                }
            },
            ConditionalLayout {
                name: "medium"
                when: layouts.width >= units.gu(40) && layouts.width <= units.gu(60)
                Flow {
                    anchors.fill: parent
                    ItemLayout {
                        item: "item1"
                    }
                    ItemLayout {
                        item: "item2"
                    }
                    ItemLayout {
                        item: "item3"
                    }
                }
            }
        ]

        DefaultLayout{
        }
    }
}