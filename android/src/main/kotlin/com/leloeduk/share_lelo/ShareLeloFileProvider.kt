package com.leloeduk.share_lelo

import androidx.core.content.FileProvider

/** Dedicated subclass to avoid manifest conflicts with other FileProviders. */
class ShareLeloFileProvider : FileProvider()
