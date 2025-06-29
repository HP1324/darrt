typedef EntityObjectListMap<T> = Map<String, List<T>>;

typedef EntityJsonListMap = Map<String, List<Map<String, dynamic>>>;

/// [JsonFactory] can also be called [fromJson]
typedef JsonFactory<T> = T Function(Map<String, dynamic> json);

/// [JsonConverter] can also be called [toJson]
typedef JsonConverter<T> = Map<String, dynamic> Function(T object);



