/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { SongItem } from 'mediacommon';

/**
 * 歌单数据模型
 */
export class PlaylistItem {
  id: number = 0;
  name: string = '';
  songs: SongItem[] = []; // 存储完整的歌曲对象
  createTime: number = 0;

  constructor(id: number, name: string) {
    this.id = id;
    this.name = name;
    this.songs = [];
    this.createTime = Date.now();
  }
}

/**
 * 简单歌单管理器
 * 负责管理歌单列表的创建和显示
 */
export class SimplePlaylistManager {
  private static instance: SimplePlaylistManager;
  
  // 响应式歌单列表
  private playlists: PlaylistItem[] = [];
  
  // ID计数器
  private nextId: number = 1;

  private constructor() {
    // 初始化默认歌单
    this.playlists.push(new PlaylistItem(this.nextId++, '我的歌单'));
  }

  /**
   * 获取单例实例
   */
  public static getInstance(): SimplePlaylistManager {
    if (!SimplePlaylistManager.instance) {
      SimplePlaylistManager.instance = new SimplePlaylistManager();
    }
    return SimplePlaylistManager.instance;
  }

  /**
   * 获取所有歌单
   */
  public getPlaylists(): PlaylistItem[] {
    return this.playlists;
  }

  /**
   * 根据ID获取歌单
   * @param id 歌单ID
   * @returns 歌单对象，如果不存在返回undefined
   */
  public getPlaylistById(id: number): PlaylistItem | undefined {
    return this.playlists.find(item => item.id === id);
  }

  /**
   * 创建新歌单
   * @param name 歌单名称
   * @returns 创建的歌单对象
   */
  public createPlaylist(name: string): PlaylistItem {
    const newPlaylist = new PlaylistItem(this.nextId++, name);
    this.playlists.push(newPlaylist);
    return newPlaylist;
  }

  /**
   * 删除歌单
   * @param id 歌单ID
   */
  public deletePlaylist(id: number): void {
    const index = this.playlists.findIndex(item => item.id === id);
    if (index !== -1) {
      this.playlists.splice(index, 1);
    }
  }

  /**
   * 获取歌单数量
   */
  public getPlaylistCount(): number {
    return this.playlists.length;
  }

  /**
   * 添加歌曲到歌单
   * @param playlistId 歌单ID
   * @param song 歌曲对象
   * @returns 是否添加成功
   */
  public addSongToPlaylist(playlistId: number, song: SongItem): boolean {
    const playlist = this.getPlaylistById(playlistId);
    if (!playlist) {
      console.error(`歌单不存在: ${playlistId}`);
      return false;
    }

    // 检查歌曲是否已存在于歌单中
    const exists = playlist.songs.some(s => s.id === song.id);
    if (exists) {
      console.warn(`歌曲已存在于歌单中: ${song.title}`);
      return false;
    }

    playlist.songs.push(song);
    console.info(`成功添加歌曲 "${song.title}" 到歌单 "${playlist.name}"`);
    return true;
  }

  /**
   * 批量添加歌曲到歌单
   * @param playlistId 歌单ID
   * @param songs 歌曲数组
   * @returns 成功添加的歌曲数量
   */
  public addSongsToPlaylist(playlistId: number, songs: SongItem[]): number {
    let successCount = 0;
    for (const song of songs) {
      if (this.addSongToPlaylist(playlistId, song)) {
        successCount++;
      }
    }
    return successCount;
  }

  /**
   * 从歌单中移除歌曲
   * @param playlistId 歌单ID
   * @param songId 歌曲ID
   * @returns 是否移除成功
   */
  public removeSongFromPlaylist(playlistId: number, songId: number): boolean {
    const playlist = this.getPlaylistById(playlistId);
    if (!playlist) {
      console.error(`歌单不存在: ${playlistId}`);
      return false;
    }

    const index = playlist.songs.findIndex(s => s.id === songId);
    if (index === -1) {
      console.warn(`歌曲不存在于歌单中: ${songId}`);
      return false;
    }

    playlist.songs.splice(index, 1);
    console.info(`成功从歌单中移除歌曲`);
    return true;
  }

  /**
   * 获取歌单中的所有歌曲
   * @param playlistId 歌单ID
   * @returns 歌曲数组，如果歌单不存在返回空数组
   */
  public getPlaylistSongs(playlistId: number): SongItem[] {
    const playlist = this.getPlaylistById(playlistId);
    if (!playlist) {
      console.error(`歌单不存在: ${playlistId}`);
      return [];
    }
    return playlist.songs;
  }

  /**
   * 更新歌单名称
   * @param playlistId 歌单ID
   * @param newName 新名称
   * @returns 是否更新成功
   */
  public updatePlaylistName(playlistId: number, newName: string): boolean {
    const playlist = this.getPlaylistById(playlistId);
    if (!playlist) {
      console.error(`歌单不存在: ${playlistId}`);
      return false;
    }
    playlist.name = newName;
    console.info(`成功更新歌单名称为: ${newName}`);
    return true;
  }
}
