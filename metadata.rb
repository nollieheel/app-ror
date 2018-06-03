name             'app-ror'
maintainer       'Chromedia Far East, Inc.'
maintainer_email 'sysadmin@chromedia.com'
license          'All rights reserved'
description      'Installs/Configures app-ror'
long_description 'Installs/Configures app-ror'
version          '0.1.0'

depends 'chef_rvm', '~> 2.0.0'
depends 'nodejs', '~> 5.0.0'
depends 'git', '~> 8.0.1'
depends 'yarn', '~> 0.4.0'

supports 'ubuntu', '14.04'
