# test-rpki-krill

実験環境として kirll を docker compose で起動する。

## .env

.env ファイルを作成する。

- RUN_USER_UID : 自分のuidを指定 (id -u 値) (コンテナ内と一致させる目的)
- RUN_USER_GID : 自分のgidを指定 (id -g 値) (コンテナ内と一致させる目的)
- SQUID_ADDR_PORT : squidのlistenアドレスとポート番号
  - squidはコンテナ内にアクセスするためのHTTPプロキシ
  - コロン区切りでアドレスとポート番号を指定
  - デフォルト値は docker-compose.yml に記載
  - ローカルホストアドレス以外を指定すると外部ホストからアクセス可能になるので注意
  - SQUID_ADDR_PORT=127.0.0.1:33128 にすると任意ホストからアクセス可能
- DOMAIN : 任意のドメイン名, テスト用TLDsを接尾辞に使用
  - TLDs (top level domain names) for Testing
    - https://datatracker.ietf.org/doc/html/rfc2606
- KRILL_ADMIN_TOKEN : adminユーザでログイン用パスワード
- KRILL_PORT: krillのポート番号

指定例

```
RUN_USER_UID=1000
RUN_USER_GID=1000
SQUID_ADDR_PORT=127.0.0.1:33128
DOMAIN=krill.test
KRILL_ADMIN_TOKEN=abcde
KRILL_PORT=3000
```

## 起動

- `./01_git-clone-pull.sh`
- `cd krill`
- (例) `git checkout v0.14.6`
  - 最新版を指定する
  - 最新版確認: <https://github.com/NLnetLabs/krill/releases>
  - git tag で他の版を確認
- `cd ..`
- `./gen-conf.sh`
  - 各コンテナ用の設定ファイルが生成される
- `docker compose build`
  - 実行省略しても良い (次の up -d で警告が出る)
  - "Compiling krill" に時間がかかる
  - ビルドに失敗した場合
    - krill 側の Dockerfile が更新される場合がある
    - ./DIFF-Dockerfile.sh を見て差分から判断する
    - 必要な差分を Dockerfile に反映する
- `docker compose up -d`

## 停止

- `docker compose down -v --remove-orphans`
  - 永続データ領域は消えずに残る
- (再開) `docker compose up -d`

## 永続データ領域

- ./data-root/
- ./data-host1/
- ./data-host2/

初期化するには、コンテナを停止し、これらを削除する。

## コンテナ内シェル利用

- `docker compose exec krill-root bash`
- `docker compose exec krill-host1 bash`
- `docker compose exec krill-host2 bash`

### root ユーザ利用

- docker compose exec -u root で起動
- ex. `docker compose exec -u root krill-root bash`

## ブラウザアクセス

- squid 経由でアクセスする
- ブラウザの設定で SQUID_ADDR_PORT に HTTP でプロキシ接続するようにする
  - これを実行しているホストに対して ssh 接続の際にポート転送も可能
    - 例: LocalForward 手元ポート番号 127.0.0.1:SQUID_ADDR_PORT
  - ブラウザ拡張 ZeroOmega を使うと便利
    - auto switch でプロキシする場合 DOMAIN で指定したホスト名をプロキシする
    - 例: *.krill.test
- (例) DOMAIN=kirll.test の場合の URL
  - <https://root.krill.test:3000/> を開く
  - <https://host1.krill.test:3000/> を開く
  - <https://host2.krill.test:3000/> を開く
  - <https://root.krill.test:3000/ui/testbed> を開く

## コマンド実行例

- (in krill-root)
  - export KRILL_CLI_TOKEN=abcde
  - export KRILL_CLI_MY_CA=testbed
  - krillc children info --child host1

## test

- make test-updown
- make test-roa
- make clean-TESTDIR

## RRDP

- https://root.krill.test:3000/rrdp/notification.xml
