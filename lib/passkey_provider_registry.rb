# パスキーを作成・管理している認証システムを AAGUID で特定するためのクラス
#
# passkeydeveloper/passkey-authenticator-aaguids に依存している
# JSON ファイルを取得するためのコマンド：
#   curl https://raw.githubusercontent.com/passkeydeveloper/passkey-authenticator-aaguids/refs/heads/main/aaguid.json
#
# passkeydeveloper/passkey-authenticator-aaguids はライセンスが未定義であり、明示的な許諾・許可なしの利用は著作権侵害とみなされるリスクがある。
# web.dev のブログに「RPs can use」と記載されているため、実際に問題が発生する可能性は限りなくゼロに近いと判断し利用する。
#
# @see https://web.dev/articles/webauthn-aaguid
# @see https://github.com/passkeydeveloper/passkey-authenticator-aaguids
# @see https://github.com/passkeydeveloper/passkey-authenticator-aaguids/issues/66
class PasskeyProviderRegistry
  DATA = JSON.parse(File.read(File.join(File.dirname(__FILE__), "passkey_provider_registry/aaguid.json")))

  # @param aaguid [String]
  # @return [Hash] スキーマは https://github.com/passkeydeveloper/passkey-authenticator-aaguids/blob/main/aaguid.json.schema を参照されたし
  def self.provider_from_aaguid(aaguid)
    DATA[aaguid.to_s]
  end
end
