{ config, pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/blob/master/modules/programs/tmux.nix
  programs.tmux = {
    enable = true;

    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-show-battery false
          set -g @dracula-show-powerline true
          set -g @dracula-refresh-rate 10
        '';
      }
    ];

    extraConfig = ''
      set -g history-limit 5000
      setw -g mode-keys vi
      set-option -g default-command ""
      set-option -g mouse on
      set-option -g status-position top
      set-option -g status-justify "left"
      set-option -g status-left "#H:[#P]"
      set-option -g status-right "#[fg=black][%Y-%m-%d %H:%M:%S]"
      set-option -g status-bg cyan
      set-option -g status-interval 1
      set-option -g base-index 1
      set-option -g pane-base-index 1
      set-option -g pane-active-border-style fg=colour31
      set-window-option -g window-status-format " [#I]#W"
      set-window-option -g window-status-current-format " [#I]#W"
# for hyper
      setw -g allow-rename on
      set-option -g automatic-rename on
      set-option -g automatic-rename-format "#(cd #{pane_current_path} && basename $(git rev-parse --show-toplevel 2>/dev/null || pwd))"

# key bindings
      bind-key | split-window -h -c '#{pane_current_path}'
      bind-key - split-window -v -c '#{pane_current_path}'
      bind c new-window -c '#{pane_current_path}'

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind-key -r H resize-pane -L 5 # -r means repeated key
      bind-key -r J resize-pane -D 5
      bind-key -r K resize-pane -U 5
      bind-key -r L resize-pane -R 5

      bind r source-file ~/.tmux.conf \; display "Reloaded!"

# when scrolled up, change to copy mode
      bind-key -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M'"

# when scrolled end, back to normal model
      bind-key -n WheelDownPane select-pane -t= \; send-keys -M

# visual mode key bindings
      bind-key v copy-mode

      unbind-key -T copy-mode-vi Enter
      unbind-key -T copy-mode-vi C-[
      unbind-key -T copy-mode-vi C-]

      bind-key -T copy-mode-vi v send-keys -X begin-selection

      if-shell "uname | grep -q Darwin" \
          "bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'"
      if-shell "uname | grep -q Darwin" \
          "bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'pbcopy'"

      if-shell "type xclip" \
          "bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -i -sel clip > /dev/null'"
      if-shell "type xclip" \
          "bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'xclip -i -sel clip > /dev/null'"
      bind-key p paste-buffer

      bind-key -T copy-mode-vi w send-keys -X next-word
      bind-key -T copy-mode-vi e send-keys -X next-word-end
      bind-key -T copy-mode-vi b send-keys -X previous-word
      bind-key -T copy-mode-vi C-[ send-keys -X clear-selection
      bind-key -T copy-mode-vi Escape send-keys -X cancel
      bind-key -T copy-mode-vi / send-keys -X search-forward
      bind-key -T copy-mode-vi ? send-keys -X search-backward
      bind-key -T copy-mode-vi g send-keys -X top-line
      bind-key -T copy-mode-vi G send-keys -X bottom-line
      bind-key -T copy-mode-vi C-b send-keys -X page-up
      bind-key -T copy-mode-vi C-f send-keys -X page-down
      bind-key -T copy-mode-vi C-u send-keys -X scroll-up
      bind-key -T copy-mode-vi C-d send-keys -X scroll-down
    '';
  };
}
