if REDIS
  require "project_syncer"
  ProjectSyncer.start
  require "project_daily_syncer"
  ProjectDailySyncer.start
end