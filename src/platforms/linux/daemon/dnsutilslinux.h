/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef DNSUTILSLINUX_H
#define DNSUTILSLINUX_H

#include "daemon/dnsutils.h"
#include "dbustypeslinux.h"

#include <QDBusInterface>
#include <QDBusPendingCallWatcher>

class DnsUtilsLinux final : public DnsUtils {
  Q_OBJECT

 public:
  DnsUtilsLinux(QObject* parent);
  ~DnsUtilsLinux();
  bool updateResolvers(const QString& ifname,
                       const QList<QHostAddress>& resolvers) override;
  bool restoreResolvers() override;

 private:
  int m_ifindex = 0;
  QMap<int, DnsLinkDomainList> m_linkDomains;
  QDBusInterface* m_resolver = nullptr;
  QDBusInterface* m_properties = nullptr;
  void setLinkDNS(int ifindex, const QList<QHostAddress>& resolvers);
  void setLinkDomains(int ifindex, const QList<DnsLinkDomain>& domains);
  void setLinkDefaultRoute(int ifindex, bool enable);
  void updateLinkDomains();

 private slots:
  void dnsCallCompleted(QDBusPendingCallWatcher*);
  void dnsDomainsReceived(QDBusPendingCallWatcher*);
};

#endif  // DNSUTILSLINUX_H
