workspace {

    !identifiers hierarchical

    model {
        properties {
            "structurizr.groupSeparator" "/"
        }

        user = person "User"

        group "External authentication providers" {
                vkAuthProvider = softwareSystem "VK OAuth 2.0" "Provides authentication with VK" "External"
                googleAuthProvider = softwareSystem "Google OAuth 2.0" "Provides authentication with Google" "External"
        }

        group "Netflix" {
            supportStaff = person "Customer Support Staff"
            admin = person "Admin"
            moderator = person "Moderator"

            netflixSystem = softwareSystem "Netflix System" "Allows users to buy subscription, view lists of contents, give a review, watch" {
                webApplication = container "Web Application" "Reverse proxy" "Nginx"
                singlePageApplication = container "Single-Page Application" "Provides functionality to customers via their web browser" "JavaScript, React, Vite" "Web Browser" {
                    fetchAuth = component "Custom fetch with auth" "Provides automatic access token attaching and refreshing"
                    services = component "Services Layer" "Provides requests to backend"
                    components = component "UI Components Layer" "Provides React components"
                    store = component "State Management" "Stores app state" "Mobx"
                }
                
                group "Subscription Service" {
                    subscriptionApi = container "Subscription Service API" "Provides functionality with subscription" "NestJS" "Hexagon" {
                        subscriptionController = component "Subscription Controller" "Handles HTTP request related to buying, canceling, checking for bought subscriptions"
                        subscriptionService = component "Subsription Service" "Provides methods to interact with subscriptions"
                        subscriptionRepository = component "Subscription Repository" "Provides methods to interact with subscriptions in database"
                        userRepository = component "User Repository" "Provides methods to interact with users in database"
                    }
                    subscriptionDb = container "Subscription Service Database" "Stores data about users' subscriptions" "PostgreSQL" "Database"
                }

                group "Support Service" {
                    supportApi = container "Support Service API" "Provides functionality to chat with customer support staff" "ASP.NET Core" "Hexagon" {
                        supportHub = component "Support Hub" "Provides functionality of chat between user and support staff" "SignalR Hub"
                        // ???
                        // historyController = component "History Controller" "Provides messages history to user" 
                        historyPublisher = component "History Publisher" "Publishes messages with chat history to broker"
                        historyService = component "History Service" "Provides methods to interact with support chat history"
                    }
                    supportBroker = container "Support Broker" "" "RabbitMQ" "Pipe"
                    supportPersistentApi = container "Support Service Persistent API" "Consumes messages to save logs of support chat" "ASP.NET Core" {
                        historyConsumer = component "History Consumer" "Consumes messages to save logs of support chat"

                        // REST для загрузки истории https://github.com/sOlnblshkO/HT.ITIS-3.1-student/blob/main/Dotnet.Homeworks.BigTask/3.1%20BigTask.md#%D1%8D%D1%82%D0%B0%D0%BF-2
                        historyController = component "History Controller" "Provides support chat history" 
                        historyService = component "History Service" "Provides methods to interact with support chat history"
                        historyRepository = component "History Repository" "Provides methods to interact with support chat history from database"
                    }
                    supportDb = container "Support Service Database" "Stores data related to users' communication with support staff" "PostgreSQL" "Database"
                }

                group "General Service" {
                    generalApi = container "General Service API" "" "" "Hexagon" {
                        contentController = component "Content controller" "Provides the user to watch content, get it's metadata, select to favourites and provides admin to CRUD operation over content" "ASP.NET Core Api Controllers"
                        reviewController = component "Review controller" "Provides the user to rate content and get other reviews" "ASP.NET Core Api Controllers"
                        commentController = component "Comment controller" "Provides the user to assign comment and get notifications about answer" "ASP.NET Core Api Controllers"
                        authController = component "Authentication controller" "Provides user's authentication" "ASP.NET Core Api Controllers"
                        
                        notificationHub = component "Notification hub" "Allows the user to be notified instantly about comment and send notification to other" "SignalR Hub"
                        
                        reviewService = component "Review service" "Provides methods to interact with reviews, connected with rating content and handling reviews" "Service"
                        favouriteService = component "Favourite service" "Provides methods to interact with favourite contents, like add to favourite and delete from favourite" "Service"
                        contentService = component "Content service" "Provides methods to interact with contents, connected with handling contents file url, data and editing it metadata " "Service"
                        commentService = component "Comment service" "Provides methods to interact with comments, connected with assigning and deleting comments" "Service"
                        notificationService = component "Notification service" "Provides methods to interact with notifications, like getting user notifications" "Service"
                        authService = component "Authentication service" "Provides methods to authenticate user" "Service"
                        redisService = component "Redis Service" "Handles interaction with Cache" "Service"
                        s3Service = component "S3 Service" "Handles interaction with S3 storage" "Service"
                        
                        emailSender = component "Email sender" "Provides methods to send messages to mail for authentication" "Service"
                        
                        identityAuth = component "Authentication identity tools" "Provides methods related to database to authenticate user"
                        
                        authProviderResolver = component "Authentication Provider Resolver" "Provides methods to resolve needed authentication provider" "Factory"
                        authProvider = component "Authentication Provider" "Provides methods to authenticate via external provider" "Service"
                        
                        contentRepository = component "Content repository" "Provides methods to interact with contents in database" "Repository"
                        favouriteRepository = component "Favourite repository" "Provides methods to interact with favourite contents in database" "Repository"
                        reviewRepository = component "Review repository" "Provides methods to interact with reviews in database" "Repository"
                        userRepository = component "User repository" "Provides methods to interact with users in database" "Repository"
                        commentRepository = component "Comment repository" "Provides methods to interact with comments in database" "Repository"
                        commentNotificationRepository = component "Comment notification repository" "Provides methods to interact with notifications in database" "Repository"
                        tokenRepository = component "Token repository" "Provides methods to interact with tokens in identity database" "Repository"
                    }

                    generalDb = container "General Database" "Stores reviews, contents' information, favourites, users" "PostgreSQL" "Database"
                    identityDb = container "Identity Database" "Stores data related to user's identity, auth" "PostgreSQL" "Database"
                    cache = container "Cache" "Caches presigned URLs from S3 storage" "Redis" "Database"
                    tempMetadaStore = container "Temporary Metadata Store" "Temporarily stores contents' metadata and information about content uploading" "Redis" "Database"
                    tempS3storage = container "Temporary S3 Storage" "Temporarily stores uploaded content" "Minio"
                    generalBroker = container "General Broker" "" "RabbitMQ" "Pipe"

                    group "Permanent S3 Service" {
                        permS3Api = container "Permanent S3 API" "Consumes messages to store content" "ASP.NET Core" "Hexagon" {
                            fileConsumer = component "File Consumer" "Consumes messages to save files" 
                            notificationPublisher = component "Notification Publisher" "Publishes message about saving process"
                            fileService = component "File Service" "Saves files in storage"
                        }
                        permS3storage = container "Permanent S3 Storage" "Permanently stores content" "Minio"
                    }

                    group "Multimedia Service" {
                        multimediaApi = container "Multimedia API" "Consumes messages to process multimedia" "ASP.NET Core" "Hexagon" {
                            fileConsumer = component "File Consumer" "Consumes messages to process files" 
                            fileService = component "File Service" "Works with files"
                            encoderFactory = component "Encoder Factory" "Provides encoder for specific file type"
                            imageEncoder = component "Image Encoder" "Encodes images"
                            movieEncoder = component "Movie Encoder" "Encodes movies"
                            seriesEncoder = component "Series Encoder" "Encodes series"
                            notificationPublisher = component "Notification Publisher" "Publishes message about encoding process"
                            logsRepository = component "Logs Repository" "Provides methods to interact with logs in database"
                        }
                        multimediaDb = container "Multimedia Database" "Stores logs" "PostgreSQL" "Database"
                    }
                }
            }
        }
        

        email = softwareSystem "E-mail System" "External e-mail system (Google)" "External"
        yandexMaps = softwareSystem "Yandex Maps" "Shows near cinemas" "External"


        user -> netflixSystem.webApplication "Uses, watches, buys subscription, gets support from staff"
        user -> supportStaff "Chats for support"
        supportStaff -> netflixSystem.webApplication "Uses to chat with user"
        admin -> netflixSystem.webApplication "Uses to CRUD content and subscriptions"
        moderator -> netflixSystem.webApplication "Uses to moderate reviews"
        
        netflixSystem.webApplication -> netflixSystem.singlePageApplication "Delivers to customer's web browser"

        netflixSystem.singlePageApplication.components -> netflixSystem.singlePageApplication.services "Uses"
        netflixSystem.singlePageApplication.services -> netflixSystem.singlePageApplication.fetchAuth "Uses"
        netflixSystem.singlePageApplication.components -> netflixSystem.singlePageApplication.store "Uses"

        netflixSystem.singlePageApplication.components -> netflixSystem.supportApi "Chatting with support staff" "SignalR"
        netflixSystem.supportApi -> netflixSystem.supportBroker "Sends messages to save chat history" "AMQP"
        netflixSystem.supportBroker -> netflixSystem.supportPersistentApi "Sends messages to save chat history" "AMQP"
        netflixSystem.supportPersistentApi -> netflixSystem.supportDb "Reads and writes to" "SQL/TCP (EF Core)"

        netflixSystem.singlePageApplication.components -> yandexMaps "Uses maps API"
        netflixSystem.singlePageApplication.fetchAuth -> netflixSystem.subscriptionApi "Manipulating with subscription" "JSON/HTTPS"
        netflixSystem.subscriptionApi -> netflixSystem.subscriptionDb "Reads and writes to" "SQL/TCP (TypeORM)"

        netflixSystem.singlePageApplication.fetchAuth -> netflixSystem.generalApi "Auth, review writing, content delivering" "JSON/HTTPS"
        netflixSystem.singlePageApplication.components -> netflixSystem.generalApi "Notifications" "SignalR"

        netflixSystem.generalApi -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi -> netflixSystem.identityDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi -> netflixSystem.cache "Reads and writes to" "TCP"
        netflixSystem.generalApi -> email "Sends e-mails using" "SMTP"
        netflixSystem.generalApi -> netflixSystem.tempMetadaStore "Reads and writes to" "RESP/TCP"

        netflixSystem.generalApi -> netflixSystem.multimediaApi "Sends message via broker to handle multimedia" "AMQP"
            netflixSystem.generalBroker -> netflixSystem.multimediaApi "Sends message to handle multimedia" "AMQP"
            netflixSystem.generalApi -> netflixSystem.generalBroker "Sends message to handle multimedia" "AMQP"
        netflixSystem.multimediaApi -> netflixSystem.multimediaDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.multimediaApi -> netflixSystem.permS3Api "Sends message via broker to save file in permanent storage" "AMQP"
            netflixSystem.multimediaApi -> netflixSystem.generalBroker "Sends message to save file in permanent storage" "AMQP" 
        netflixSystem.multimediaApi -> netflixSystem.tempS3storage "Reads and writes to" "S3/TCP"

        netflixSystem.generalApi -> netflixSystem.tempS3storage "Reads and writes to" "S3/TCP" 

        netflixSystem.generalBroker -> netflixSystem.permS3Api "Sends message to save file in permanent storage" "AMQP" 
        netflixSystem.permS3Api -> netflixSystem.generalApi "Sends message via broker about successful upload" "AMQP"
        netflixSystem.permS3Api -> netflixSystem.permS3storage "Reads and writes to" "S3/TCP" 
        
        netflixSystem.singlePageApplication -> netflixSystem.generalApi.contentController "Makes API calls to" "JSON/HTTPS"
        netflixSystem.singlePageApplication -> netflixSystem.generalApi.reviewController "Makes API calls to" "JSON/HTTPS"
        netflixSystem.singlePageApplication -> netflixSystem.generalApi.commentController "Makes API calls to" "JSON/HTTPS"
        netflixSystem.singlePageApplication -> netflixSystem.generalApi.authController "Makes API calls to" "JSON/HTTPS"
        netflixSystem.singlePageApplication -> netflixSystem.generalApi.notificationHub "Makes remote procedure calls to" "SignalR/WebSockets"
        
        netflixSystem.generalApi.contentController -> netflixSystem.generalApi.contentService "Uses" "Interface"
        netflixSystem.generalApi.contentController -> netflixSystem.generalApi.favouriteService "Uses" "Interface"
        
        netflixSystem.generalApi.reviewController -> netflixSystem.generalApi.reviewService "Uses" "Interface"
        
        netflixSystem.generalApi.commentController -> netflixSystem.generalApi.commentService "Uses" "Interface"
        netflixSystem.generalApi.commentController -> netflixSystem.generalApi.notificationService "Uses" "Interface"
        
        netflixSystem.generalApi.authController -> netflixSystem.generalApi.authService "Uses" "Interface"
        netflixSystem.generalApi.authController -> netflixSystem.generalApi.authProviderResolver "Uses" "Interface"
        
        netflixSystem.generalApi.notificationHub -> netflixSystem.generalApi.notificationService "Uses" "Interface"
        
        netflixSystem.generalApi.contentService -> netflixSystem.generalApi.contentRepository "Uses" "Interface"
        netflixSystem.generalApi.contentService -> netflixSystem.generalApi.userRepository "Uses" "Interface"
        netflixSystem.generalApi.contentService -> netflixSystem.subscriptionApi "Gets subscriptions" "JSON/HTTPS"
        netflixSystem.generalApi.contentService -> netflixSystem.generalApi.redisService "Uses for caching metadata and incrementing values"
        netflixSystem.generalApi.contentService -> netflixSystem.generalApi.s3Service "Uses for reading and writing multimedia"

        netflixSystem.generalApi.redisService -> netflixSystem.cache "Reads and writes to" "TCP"
        netflixSystem.generalApi.s3Service -> netflixSystem.tempS3storage "Writes to" "S3/TCP"
        netflixSystem.generalApi.s3Service -> netflixSystem.permS3storage "Reads from" "S3/TCP"
        
        netflixSystem.generalApi.favouriteService -> netflixSystem.generalApi.contentRepository "Uses" "Interface"
        netflixSystem.generalApi.favouriteService -> netflixSystem.generalApi.userRepository "Uses" "Interface"
        netflixSystem.generalApi.favouriteService -> netflixSystem.generalApi.favouriteRepository "Uses" "Interface"
        
        netflixSystem.generalApi.reviewService -> netflixSystem.generalApi.userRepository "Uses" "Interface"
        netflixSystem.generalApi.reviewService -> netflixSystem.generalApi.contentRepository "Uses" "Interface"
        netflixSystem.generalApi.reviewService -> netflixSystem.generalApi.reviewRepository "Uses" "Interface"
        
        netflixSystem.generalApi.commentService -> netflixSystem.generalApi.commentRepository "Uses" "Interface"
        netflixSystem.generalApi.commentService -> netflixSystem.generalApi.userRepository "Uses" "Interface"
        netflixSystem.generalApi.commentService -> netflixSystem.generalApi.reviewRepository "Uses" "Interface"
        
        netflixSystem.generalApi.notificationService -> netflixSystem.generalApi.userRepository "Uses" "Interface"
        netflixSystem.generalApi.notificationService -> netflixSystem.generalApi.commentNotificationRepository "Uses" "Interface"
        
        netflixSystem.generalApi.authService -> netflixSystem.generalApi.userRepository "Uses" "Interface"
        netflixSystem.generalApi.authService -> netflixSystem.generalApi.identityAuth "Uses" "Abstract"
        netflixSystem.generalApi.authService -> netflixSystem.generalApi.tokenRepository "Uses" "Interface"
        netflixSystem.generalApi.authService -> netflixSystem.generalApi.emailSender "Uses" "Interface"
        
        netflixSystem.generalApi.authProviderResolver -> netflixSystem.generalApi.authProvider "Uses" "Interface"
        netflixSystem.generalApi.authProvider -> vkAuthProvider "Makes API calls to" "JSON/HTTPS"
        netflixSystem.generalApi.authProvider -> googleAuthProvider "Makes API calls to" "JSON/HTTPS"
        netflixSystem.generalApi.emailSender -> email "Sends e-mails using" "SMTP"
        
        netflixSystem.generalApi.userRepository -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi.contentRepository -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi.reviewRepository -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi.favouriteRepository -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi.commentRepository -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi.commentNotificationRepository -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi.tokenRepository -> netflixSystem.identityDb  "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi.identityAuth -> netflixSystem.identityDb  "Reads and writes to" "SQL/TCP (EF Core)"


        netflixSystem.generalBroker -> netflixSystem.multimediaApi.fileConsumer "Sends message to handle multimedia" "AMQP"
        netflixSystem.multimediaApi.fileConsumer -> netflixSystem.multimediaApi.fileService "Uses"
        netflixSystem.multimediaApi.fileService -> netflixSystem.multimediaApi.encoderFactory "Uses"
        netflixSystem.multimediaApi.fileService -> netflixSystem.multimediaApi.notificationPublisher "Uses"
        netflixSystem.multimediaApi.notificationPublisher -> netflixSystem.generalBroker "Sends messages about file processing process"
        netflixSystem.multimediaApi.encoderFactory -> netflixSystem.multimediaApi.imageEncoder "Uses"
        netflixSystem.multimediaApi.encoderFactory -> netflixSystem.multimediaApi.movieEncoder "Uses"
        netflixSystem.multimediaApi.encoderFactory -> netflixSystem.multimediaApi.seriesEncoder "Uses"
        netflixSystem.multimediaApi.fileService -> netflixSystem.multimediaApi.logsRepository "Uses"
        netflixSystem.multimediaApi.logsRepository -> netflixSystem.multimediaDb "Reads and writes to" "SQL/TCP (EF Core)"


        netflixSystem.generalBroker -> netflixSystem.permS3Api.fileConsumer "Sends messages to save file" "AMQP"
        netflixSystem.permS3Api.fileConsumer -> netflixSystem.permS3Api.fileService "Uses"
        netflixSystem.permS3Api.fileService -> netflixSystem.permS3storage "Reads and writes to" "S3/TCP"
        netflixSystem.permS3Api.fileService -> netflixSystem.permS3Api.notificationPublisher "Uses"
        netflixSystem.permS3Api.notificationPublisher -> netflixSystem.generalBroker "Sends messages about file saving process"


        netflixSystem.singlePageApplication -> netflixSystem.supportApi.supportHub "Chatting" "SignalR"
        netflixSystem.supportApi.supportHub -> netflixSystem.supportApi.historyService "Uses"
        netflixSystem.supportApi.historyService -> netflixSystem.supportApi.historyPublisher "Uses"
        netflixSystem.supportApi.historyPublisher -> netflixSystem.supportBroker "Sends messages to save chat history" "AMQP"
        netflixSystem.supportApi.historyService -> netflixSystem.supportPersistentApi.historyController "Gets history" "JSON/HTTPS"

        netflixSystem.supportBroker -> netflixSystem.supportPersistentApi.historyConsumer "Consumes messages to save chat history" "AMQP"
        netflixSystem.supportPersistentApi.historyConsumer -> netflixSystem.supportPersistentApi.historyService "Uses"
        netflixSystem.supportPersistentApi.historyController -> netflixSystem.supportPersistentApi.historyService "Uses"
        netflixSystem.supportPersistentApi.historyService -> netflixSystem.supportPersistentApi.historyRepository "Uses"
        netflixSystem.supportPersistentApi.historyRepository -> netflixSystem.supportDb "Reads and writes to" "SQL/TCP (EF Core)"


        netflixSystem.singlePageApplication -> netflixSystem.subscriptionApi.subscriptionController "Makes API calls to" "JSON/HTTPS"
        netflixSystem.subscriptionApi.subscriptionController -> netflixSystem.subscriptionApi.subscriptionService "Uses"
        netflixSystem.subscriptionApi.subscriptionService -> netflixSystem.subscriptionApi.subscriptionRepository "Uses"
        netflixSystem.subscriptionApi.subscriptionService -> netflixSystem.subscriptionApi.userRepository "Uses"
        netflixSystem.subscriptionApi.subscriptionRepository -> netflixSystem.subscriptionDb "Reads and writes to" "SQL/TCP (TypeORM)"
        netflixSystem.subscriptionApi.userRepository -> netflixSystem.subscriptionDb "Reads and writes to" "SQL/TCP (TypeORM)"

        email -> user "Sends e-mails to"
    }

    views {
        systemlandscape "SystemLandscape" {
            include *
            exclude email
            autoLayout lr
        }

        systemContext netflixSystem "SystmContext" {
            include *
            autolayout tb
        }

        container netflixSystem "ContainerContext" {
            include *
            exclude netflixSystem.generalBroker
            autolayout tb
        }
        
        component netflixSystem.generalApi "ComponentContext_General_API" {
            include *
            autolayout tb
        }

        component netflixSystem.singlePageApplication "ComponentContext_SPA" {
            include *
            autolayout tb
        }

        component netflixSystem.multimediaApi "ComponentContext_Multimedia_API" {
            include *
            autolayout tb
        }

        component netflixSystem.permS3Api "ComponentContext_Permanent_S3_API" {
            include *
            autolayout tb 
        }

        component netflixSystem.supportApi "ComponentContext_Support_API" {
            include *
            autolayout tb
        }

        component netflixSystem.supportPersistentApi "ComponentContext_Support_Persistent_API" {
            include *
            autolayout tb
        }

        component netflixSystem.subscriptionApi "ComponentContext_Subscription_API" {
            include *
            autolayout tb
        }
        
        image netflixSystem.subscriptionApi "CodeContext_Subscription_Service"{
            image "./subscription_service/sub_service_code.png"
            title "[Code] Netflix - System Subscription Service"
        }

        styles {
            element "Element" {
                color #ffffff
            }
            element "Person" {
                background #9b191f
                shape person
            }
            element "Software System" {
                background #ba1e25
            }
            element "Container" {
                background #d9232b
            }
            element "Component" {
                background #d9232b
            }
            element "Database" {
                shape cylinder
            }
            element "Web Browser" {
                shape "WebBrowser"
            }
            element "Hexagon" {
                shape "Hexagon"
            }
            element "External" {
                background "#888888"
            }
            element "Pipe" {
                shape "Pipe"
            }
        }
    }

    configuration {
        scope softwaresystem
    }

}