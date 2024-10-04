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
                singlePageApplication = container "Single-Page Application" "Provides functionality to customers via their web browser" "JavaScript, React, Vite" "Web Browser"
                
                group "Subscription Service" {
                    subscriptionApi = container "Subscription Service API" "Provides functionality with subscription (buying, checking for bought ones) via JSON/HTTPS API" "NestJS" "Hexagon"
                    subscriptionDb = container "Subscription Service Database" "Stores data about users' subscriptions" "PostgreSQL" "Database"
                }

                group "Support Service" {
                    supportApi = container "Support Service API" "Provides functionality to chat with customer support staff" "ASP.NET Core" "Hexagon"
                    supportBroker = container "Support Broker" "" "RabbitMQ" "Pipe"
                    supportPersistentApi = container "Support Service Persistent API" "Consumes messages to save logs of support chat" "ASP.NET Core"
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
                    // generalBroker = container "General Broker" "" "RabbitMQ" "Pipe"

                    group "Permanent S3 Service" {
                        permS3Api = container "Permanent S3 API" "Consumes messages to store content" "ASP.NET Core" "Hexagon"
                        permS3storage = container "Permanent S3 Storage" "Permanently stores content" "Minio"
                    }

                    group "Multimedia Service" {
                        multimediaApi = container "Multimedia API" "Consumes messages to process multimedia" "ASP.NET Core" "Hexagon"
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

        netflixSystem.singlePageApplication -> netflixSystem.supportApi "Chatting with support staff" "SignalR"
        netflixSystem.supportApi -> netflixSystem.supportBroker "Sends command to save messages" "AMQP"
        netflixSystem.supportBroker -> netflixSystem.supportPersistentApi "Sends command to save messages" "AMQP"
        netflixSystem.supportPersistentApi -> netflixSystem.supportDb "Reads and writes to" "SQL/TCP (EF Core)"

        netflixSystem.singlePageApplication -> yandexMaps "Uses maps API"
        netflixSystem.singlePageApplication -> netflixSystem.subscriptionApi "Manipulating with subscription" "JSON/HTTPS"
        netflixSystem.subscriptionApi -> netflixSystem.subscriptionDb "Reads and writes to" "SQL/TCP (TypeORM)"

        netflixSystem.singlePageApplication -> netflixSystem.generalApi "Auth, review writing, content delivering" "JSON/HTTPS"
        netflixSystem.generalApi -> netflixSystem.generalDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi -> netflixSystem.identityDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.generalApi -> netflixSystem.cache "Reads and writes to" "TCP"
        netflixSystem.generalApi -> email "Sends e-mails using" "SMTP"
        netflixSystem.generalApi -> netflixSystem.tempMetadaStore "Reads and writes to" "RESP/TCP"

        netflixSystem.generalApi -> netflixSystem.multimediaApi "Sends message via broker to handle multimedia" "AMQP"
        // netflixSystem.generalBroker -> netflixSystem.multimediaApi "Sends message to handle multimedia" "AMQP"
        netflixSystem.multimediaApi -> netflixSystem.multimediaDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.multimediaApi -> netflixSystem.permS3Api "Sends message via broker to save file in permanent storage" "AMQP"
        netflixSystem.multimediaApi -> netflixSystem.tempS3storage "Reads and writes to" "S3/TCP"

        // netflixSystem.multimediaApi -> netflixSystem.generalBroker "Sends message to save file" "AMQP"
        // netflixSystem.generalApi -> netflixSystem.tempS3Api "Sends request to save file" "HTTP"
        netflixSystem.generalApi -> netflixSystem.tempS3storage "Reads and writes to" "S3/TCP" 

        // netflixSystem.generalBroker -> netflixSystem.permS3Api "Sends message to save file in permanent storage" "AMQP" 
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
            autolayout tb
        }
        
        component netflixSystem.generalApi "ComponentContext" {
            include *
            autolayout tb
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