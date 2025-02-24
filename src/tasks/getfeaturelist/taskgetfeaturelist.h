/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef TASKGETFEATURELIST_H
#define TASKGETFEATURELIST_H

#include "task.h"
#include "mozillavpn.h"

#include <QObject>

class TaskGetFeatureList final : public Task {
  Q_DISABLE_COPY_MOVE(TaskGetFeatureList)

 public:
  TaskGetFeatureList();
  ~TaskGetFeatureList();

  void run(MozillaVPN* vpn) override;
};

#endif  // TASKGETFEATURELIST_H
