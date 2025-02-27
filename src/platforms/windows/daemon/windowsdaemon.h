/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef WINDOWSDAEMON_H
#define WINDOWSDAEMON_H

#include "daemon/daemon.h"
#include "dnsutilswindows.h"
#include "windowstunnelservice.h"
#include "wireguardutilswindows.h"
#include "windowssplittunnel.h"

#define TUNNEL_SERVICE_NAME L"WireGuardTunnel$MozillaVPN"

class WindowsDaemon final : public Daemon {
  Q_DISABLE_COPY_MOVE(WindowsDaemon)

 public:
  WindowsDaemon();
  ~WindowsDaemon();

  QByteArray getStatus() override;
  void prepareActivation(const InterfaceConfig& config) override;

 protected:
  bool run(Op op, const InterfaceConfig& config) override;
  WireguardUtils* wgutils() const override { return m_wgutils; }
  bool supportDnsUtils() const override { return true; }
  DnsUtils* dnsutils() override { return m_dnsutils; }

 private:
  void monitorBackendFailure();

 private:
  enum State {
    Active,
    Inactive,
  };

  State m_state = Inactive;
  int m_inetAdapterIndex = -1;

  WireguardUtilsWindows* m_wgutils = nullptr;
  DnsUtilsWindows* m_dnsutils = nullptr;
  WindowsSplitTunnel m_splitTunnelManager;
};

#endif  // WINDOWSDAEMON_H
