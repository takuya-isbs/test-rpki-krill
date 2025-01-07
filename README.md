## .env

- RUN_USER_UID : 自分のuidを指定
- RUN_USER_GID : 自分のgidを指定
- SQUID_ADDR_PORT : squidのlistenアドレスとポート番号
  - コロン区切りでアドレスとポート番号を指定
  - デフォルト値は docker-compose.yml に記載
  - ローカルホストアドレス以外にすると他のホストからアクセス可能になるので注意
- DOMAIN : 任意のテスト用ドメイン名
  - https://datatracker.ietf.org/doc/html/rfc2606
- KRILL_ADMIN_TOKEN : adminユーザでログイン用パスワード

設定例

```
RUN_USER_UID=1000
RUN_USER_GID=1000
SQUID_ADDR_PORT=127.0.0.1:33128
DOMAIN=krill.test
KRILL_ADMIN_TOKEN=abcde
```

## 起動

- ./01_git-clone-pull.sh
- ./gen-conf.sh
- docker compose up -d

## ブラウザアクセス

- squid 経由でアクセスする
- ブラウザの設定で SQUID_ADDR_PORT に HTTP でプロキシ接続するようにする
  - ssh ポート転送も可能
  - ブラウザ拡張 ZeroOmega を使うと便利
    - 自動でプロキシする場合 DOMAIN で指定したホスト名をプロキシする
- 以下 DOMAIN=kirll.test の例
- https://root.krill.test:3000/ を開く
- https://host1.krill.test:3000/ を開く
- https://root.krill.test:3000/ui/testbed を開く

## コマンド

- docker compose exec krill-root bash
- krillc --token abcde children info --ca testbed --child host1
