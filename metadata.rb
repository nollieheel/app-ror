name             'app_ror'
maintainer       'Earth U'
maintainer_email 'iskitingbords@gmail.com'
license          'Apache-2.0'
description      'Wrapper cookbook for setting up Ruby on Rails apps'
source_url       'https://github.com/nollieheel/app-ror'
issues_url       'https://github.com/nollieheel/app-ror/issues'
version          '5.0.1'

depends 'app_add_apt', '~> 1.0.0'
depends 'git',         '~> 12.1.3'
depends 'ruby_build',  '~> 2.5.7'

chef_version '>= 18.3'
supports     'ubuntu', '>= 22.04'
