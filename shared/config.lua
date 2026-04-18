Config = {}

Config.AnimTime     = 3000
Config.MaxDistance  = 2.5

Config.HospitalCoords = vector3(239.17, -1380.86, 33.74)

Config.RequireItem  = false
Config.ItemName     = 'bodybag'

Config.AuthorisedJobs = {}  -- empty = anyone can use

Config.BagModel = 'xm_prop_body_bag'

Config.Notifications = {
    noBagNearby     = 'No body bag nearby.',
    noDeadNearby    = 'No dead player nearby.',
    notAuthorised   = 'You are not authorised to do this.',
    noItem          = "You don't have a body bag.",
    bagged          = 'Body bagged.',
    removed         = 'Body bag removed.',
}
