/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef WINDOWSSERVICEMANAGER
#define WINDOWSSERVICEMANAGER
#include <Windows.h>
#include "Windows.h"
#include "Winsvc.h"
#include <QTimer>
#include <QObject>

/**
 * @brief The WindowsServiceManager provides controll over the MozillaVPNBroker service via SCM
 */
class WindowsServiceManager : public QObject {
  Q_OBJECT
  Q_DISABLE_COPY_MOVE(WindowsServiceManager)

 public:
    WindowsServiceManager();
  ~WindowsServiceManager();

  // true if the Service is running
  bool isRunning(){ return getStatus().dwCurrentState == SERVICE_RUNNING;};

  // Starts the service if execute rights are present
  // Starts to poll for serviceStarted
  bool startService();

  // Stops the service if execute rights are present.
  // Starts to poll for serviceStopped
  bool stopService();

public slots:
  void pollStatus();


 signals:
 // Gets Emitted after the Service moved From SERVICE_START_PENDING to SERVICE_RUNNING
  void serviceStarted();
  void serviceStopped();

 private:
    // Returns the State of the Process:
    // See SERVICE_STOPPED,SERVICE_STOP_PENDING,SERVICE_START_PENDING,SERVICE_RUNNING
    SERVICE_STATUS_PROCESS getStatus();
    bool m_has_access = false;
    LPCWSTR m_serviceName = L"MozillaVPNBroker";
    SC_HANDLE m_serviceManager; 
    SC_HANDLE m_service; // Service handle with r/w priv.
    DWORD m_state_target;
    int m_currentWaitTime;
    int m_maxWaitTime;
    QTimer m_timer;

    void startPolling(DWORD goal_state, int maxS);

};

#endif  // WINDOWSSERVICEMANAGER
