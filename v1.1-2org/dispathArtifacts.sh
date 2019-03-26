#!/bin/bash +x
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


#set -e

rm -rf centos-1/e2e_cli/channel-artifacts centos-1/e2e_cli/crypto-config
cp -rf channel-artifacts crypto-config centos-1/e2e_cli/
rm -rf centos-2/e2e_cli/channel-artifacts centos-2/e2e_cli/crypto-config
cp -rf channel-artifacts crypto-config centos-2/e2e_cli/
rm -rf centos-3/e2e_cli/channel-artifacts centos-3/e2e_cli/crypto-config
cp -rf channel-artifacts crypto-config centos-3/e2e_cli/
rm -rf centos-4/e2e_cli/channel-artifacts centos-4/e2e_cli/crypto-config
cp -rf channel-artifacts crypto-config centos-4/e2e_cli/
rm -rf centos-5/e2e_cli/channel-artifacts centos-5/e2e_cli/crypto-config
cp -rf channel-artifacts crypto-config centos-5/e2e_cli/