{ pkgs, ... }:
{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/aerospace.nix
  # 役割: ワークスペース管理のみ。レイアウトは Raycast に委任。
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      start-at-login = true;
      after-startup-command = [
        "exec-and-forget ${pkgs.jankyborders}/bin/borders style=round active_color=0xffe2e2e3 inactive_color=0x40ffffff width=12.0 hidpi=on"
      ];

      gaps = {
        inner.horizontal = 8;
        inner.vertical = 8;
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
      };

      mode.main.binding = {
        # ワークスペース切り替え
        alt-1 = "workspace 1";
        alt-2 = "workspace 2";
        alt-3 = "workspace 3";
        alt-4 = "workspace 4";
        alt-5 = "workspace 5";
        alt-6 = "workspace 6";
        alt-7 = "workspace 7";
        alt-8 = "workspace 8";
        alt-9 = "workspace 9";

        # ウィンドウをワークスペースに移動
        alt-shift-1 = "move-node-to-workspace 1";
        alt-shift-2 = "move-node-to-workspace 2";
        alt-shift-3 = "move-node-to-workspace 3";
        alt-shift-4 = "move-node-to-workspace 4";
        alt-shift-5 = "move-node-to-workspace 5";
        alt-shift-6 = "move-node-to-workspace 6";
        alt-shift-7 = "move-node-to-workspace 7";
        alt-shift-8 = "move-node-to-workspace 8";
        alt-shift-9 = "move-node-to-workspace 9";

        # フォーカス移動
        alt-h = "focus left";
        alt-j = "focus down";
        alt-k = "focus up";
        alt-l = "focus right";

        # ウィンドウ移動（タイルモード時）
        alt-shift-h = "move left";
        alt-shift-j = "move down";
        alt-shift-k = "move up";
        alt-shift-l = "move right";

        # レイアウト切り替え
        alt-slash = "layout tiles horizontal vertical";
        alt-comma = "layout accordion horizontal vertical";

        # サイズ均等化
        alt-shift-equal = "balance-sizes";

        alt-tab = "workspace-back-and-forth";
        alt-shift-n = "move-node-to-monitor next";
        alt-r = "mode resize";

        # Raycast でレイアウトを調整する前にフロートに切り替える
        alt-shift-f = "layout floating tiling";
      };

      mode.resize.binding = {
        h = "resize width -50";
        j = "resize height -50";
        k = "resize height +50";
        l = "resize width +50";
        enter = "mode main";
        esc = "mode main";
      };

      # Slack をワークスペース 9 に自動配置（alt-9 でアクセス）
      on-window-detected = [
        {
          "if".app-id = "com.tinyspeck.slackmacgap";
          run = "move-node-to-workspace 9";
        }
      ];
    };
  };
}
