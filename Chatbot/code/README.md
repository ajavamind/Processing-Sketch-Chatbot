This folder contains the  OpenAI-java interface jar files
This is version 0.0.15
OpenAiService.java was modified to be able to use a custom base URL for the OpenAI server interface.
 https://github.com/TheoKanning/openai-java/blob/main/service/src/main/java/com/theokanning/openai/service/OpenAiService.java#L58
 
 Added constructor and static method :
 
     /**
     * Creates a new OpenAiService that wraps OpenAiApi
     *
     * @param token   OpenAi token string "sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
     * @param timeout http read timeout, Duration.ZERO means no timeout
	 * @param baseUrl URL for openai or alternate 
     */
    public OpenAiService(final String token, final Duration timeout, String baseUrl) {
        ObjectMapper mapper = defaultObjectMapper();
        OkHttpClient client = defaultClient(token, timeout);
        Retrofit retrofit = customRetrofit(client, mapper, baseUrl);

        this.api = retrofit.create(OpenAiApi.class);
        this.executorService = client.dispatcher().executorService();
    }

    public static Retrofit customRetrofit(OkHttpClient client, ObjectMapper mapper, String baseUrl) {
        return new Retrofit.Builder()
                .baseUrl(baseUrl)
                .client(client)
                .addConverterFactory(JacksonConverterFactory.create(mapper))
                .addCallAdapterFactory(RxJava2CallAdapterFactory.create())
                .build();
    }

