const path = require('path');
const fs = require('fs');
const plist = require('plist');
const { ConfigParser } = require('cordova-common');

module.exports = function (context) {
    const projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;
    const configXML = path.join(projectRoot, 'config.xml');
    const configParser = new ConfigParser(configXML);

    const userTrackingDescription = configParser.getPlatformPreference("USER_TRACKING_DESCRIPTION_IOS", "ios");
    if (!userTrackingDescription || userTrackingDescription.length === 0) {
        return;
    }

    const appName = configParser.name();
    const infoPlistPath = path.join(projectRoot, `platforms/ios/${appName}/${appName}-info.plist`);
    const plistContent = plist.parse(fs.readFileSync(infoPlistPath, 'utf8'));
    plistContent['NSUserTrackingUsageDescription'] = userTrackingDescription;
    fs.writeFileSync(infoPlistPath, plist.build(plistContent));
};