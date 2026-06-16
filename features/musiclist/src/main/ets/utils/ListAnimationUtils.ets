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

/**
 * 入场动画配置接口
 */
export interface EntranceConfig {
  duration: number;    // 动画时长（ms）
  delay: number;       // 每个item延迟（ms）
  translateY: number;  // Y轴偏移量
  curve: Curve;        // 动画曲线
}

/**
 * 按压反馈配置接口
 */
export interface PressConfig {
  scale: number;       // 按压缩放比例
  duration: number;    // 动画时长（ms）
}

/**
 * 列表项动画状态接口
 */
export interface ListItemAnimationState {
  opacity: number;
  translateY: number;
  scale: number;
}

/**
 * 列表动画工具类
 * 提供入场动画和按压反馈的通用实现
 */
export class ListAnimationUtils {
  /**
   * 入场动画配置
   */
  static get ENTRANCE_CONFIG(): EntranceConfig {
    return {
      duration: 300,        // 动画时长（ms）
      delay: 30,            // 每个item延迟（ms）
      translateY: 20,       // Y轴偏移量
      curve: Curve.EaseOut  // 动画曲线
    };
  }

  /**
   * 按压反馈配置
   */
  static get PRESS_CONFIG(): PressConfig {
    return {
      scale: 0.96,          // 按压缩放比例
      duration: 100         // 动画时长（ms）
    };
  }

  /**
   * 计算入场动画延迟时间
   * @param index 列表项索引
   * @returns 延迟时间（ms）
   */
  static getEntranceDelay(index: number): number {
    return index * ListAnimationUtils.ENTRANCE_CONFIG.delay;
  }
}

/**
 * 创建默认的列表项动画状态
 */
export function createDefaultAnimationState(): ListItemAnimationState {
  return {
    opacity: 0,
    translateY: ListAnimationUtils.ENTRANCE_CONFIG.translateY,
    scale: 1
  };
}

/**
 * 创建已完成的列表项动画状态
 */
export function createCompletedAnimationState(): ListItemAnimationState {
  return {
    opacity: 1,
    translateY: 0,
    scale: 1
  };
}
