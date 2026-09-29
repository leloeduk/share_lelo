package com.leloeduk.share_lelo

import androidx.core.content.FileProvider

/** Sous-classe dédiée pour éviter les conflits de manifest avec d'autres FileProvider. */
class ShareLeloFileProvider : FileProvider()
