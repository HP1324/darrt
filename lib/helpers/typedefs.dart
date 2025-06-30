import 'package:flutter/material.dart';

typedef EntityObjectListMap<T> = Map<String, List<T>>;

typedef EntityJsonListMap = Map<String, dynamic>;

typedef EntityJsonList = List<Map<String,dynamic>>;

typedef EntityObjectList<T> = List<T>;

/// [JsonFactory] can also be called [fromJson]
typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

/// [JsonConverter] can also be called [toJson]
typedef JsonConverter<T> = Map<String, dynamic> Function(T object);

typedef OneTimeCompletions = ValueNotifier<Map<int, bool>>;

typedef RepeatingCompletions = ValueNotifier<Map<int, Set<int>>>;



