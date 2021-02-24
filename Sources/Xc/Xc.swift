import Foundation

@objc(MNLXc)
public final class Xc: NSObject {

    @objc(defaultXc)
    public class var `default`: Self {
        return unsafeDowncast(_defaultXcInstance, to: self)
    }

    private let _query = NSMetadataQuery()
    private let _dsema = DispatchSemaphore(value: 0)

    private var _xcodes = [Xcode]()

    public var xcodes: [Xcode] {
        return self._xcodes
    }

    public override init() {
        super.init()
        self._query.operationQueue = OperationQueue()
        let predicateString =
            String(format: "(%@ == %@) && (%@ == %@)",
                   kMDItemContentType as NSString,
                   "'com.apple.application-bundle'",
                   kMDItemCFBundleIdentifier as NSString,
                   "'com.apple.dt.Xcode'")
        self._query.predicate = NSPredicate(fromMetadataQueryString: predicateString)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(_metadataQueryDidFinishGathering(_:)),
            name: .NSMetadataQueryDidFinishGathering, object: nil)
        self._query.operationQueue!.addOperation {
            self._query.start()
        }
        self._dsema.wait()
    }

    @objc
    private func _metadataQueryDidFinishGathering(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name: notification.name, object: nil)
        self._query.operationQueue!.addOperation {
            var apps = [Xcode]()
            for result in self._query.results {
                guard let item = result as? NSMetadataItem
                else {
                    continue
                }
                let _kMDItemAppStoreIsAppleSigned = "kMDItemAppStoreIsAppleSigned"
                let _kMDItemFSName = "kMDItemFSName"
                let _kMDItemVersion = kMDItemVersion as NSString as String
                let attributes = (item.values(forAttributes: [_kMDItemAppStoreIsAppleSigned, _kMDItemFSName, _kMDItemVersion, _kMDItemVersion]) ?? [:]).mapValues({$0 as AnyObject})
                let isAppleSigned = unsafeDowncast(attributes[_kMDItemAppStoreIsAppleSigned]!, to: NSNumber.self).boolValue
                let fsName = unsafeDowncast(attributes[_kMDItemFSName]!, to: NSString.self) as String
                let version = Version(string: unsafeDowncast(attributes[_kMDItemVersion]!, to: NSString.self) as String)
                guard isAppleSigned
                else {
                    continue
                }
                apps.append(Xcode(name: fsName, version: version))
            }
            apps.sort(by: {$0.build > $1.build})
            self._xcodes = apps
            self._dsema.signal()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: nil, object: nil)
        self._query.stop()
    }
}

private let _defaultXcInstance = Xc()
