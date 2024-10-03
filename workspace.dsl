workspace {

    !identifiers hierarchical

    model {
        user = person "User"

        group "Netflix" {
            supportStaff = person "Customer Service Staff"
            admin = person "Admin"

            netflixSystem = softwareSystem "Netflix System" "Allows users to buy subscription, view lists of contents, give a review, watch" {
                webApplication = container "Web Application" "Reverse proxy" "Nginx"
                singlePageApplication = container "Single-Page Application" "Provides functionality to customers via their web browser" "JavaScript, React, Vite" "Web Browser"
                
                group "Subscription Service" {
                    subscriptionApi = container "Subscription Service API" "Provides functionality with subscription (buying, checking for bought ones) via JSON/HTTPS API" "NestJS" "Hexagon"
                    subscriptionDb = container "Subscription Service Database" "Stores data about users' subscriptions" "PostgreSQL" "Database"
                }

                group "Support Service" {
                    supportApi = container "Support Service API" "" "" "Hexagon"
                    supportBroker = container "Support Broker" "" "RabbitMQ" "Pipe"
                    supportPersistentApi = container "Support Service Persistent API" "" ""
                    supportDb = container "Support Service Database" "Stores data related to users' communication with support staff" "PostgreSQL" "Database"
                }

                group "General Service" {
                    generalApi = container "General Service API" "" "" "Hexagon"
                    generalBroker = container "General Broker" "" "RabbitMQ" "Pipe"
                    generalDb = container "General Database" "Stores reviews, contents' information, favourites, users" "PostgreSQL" "Database"
                    identityDb = container "Identity Database" "Stores data related to user's identity, auth" "PostgreSQL" "Database"
                    cache = container "Cache" "Caches presigned URLs from S3 storage" "Redis" "Database"
                    tempMetadaStore = container "Temporary Metadata Store" "" "Redis" "Database"
                    tempS3storage = container "Temporary S3 Storage"
                }

                group "Permanent S3 Service" {
                    permS3Api = container "Permanent S3 API" "" "" "Hexagon"
                    permS3storage = container "Permanent S3 Storage"
                }

                group "Multimedia Service" {
                    multimediaApi = container "Multimedia API" "" "" "Hexagon"
                    multimediaDb = container "Multimedia Database" "" "" "Database"
                }

            }
        }
        

        email = softwareSystem "E-mail System" "External e-mail system (Google)" "External"
        yandexMaps = softwareSystem "Yandex Maps" "" "External"


        user -> netflixSystem.webApplication "Uses, watches, buys subscription, gets support from staff"
        user -> supportStaff "Chats for support"
        supportStaff -> netflixSystem.webApplication "Uses to chat with user"
        admin -> netflixSystem.webApplication "Uses to CRUD content and subscriptions"

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
        netflixSystem.generalApi -> email "Sends e-mails using"
        netflixSystem.generalApi -> netflixSystem.tempMetadaStore "Sends metadata" 

        netflixSystem.generalApi -> netflixSystem.generalBroker "Sends message to handle multimedia" "AMQP"
        netflixSystem.generalBroker -> netflixSystem.multimediaApi "Sends message to handle multimedia" "AMQP"
        netflixSystem.multimediaApi -> netflixSystem.multimediaDb "Reads and writes to" "SQL/TCP (EF Core)"
        netflixSystem.multimediaApi -> netflixSystem.generalBroker "Sends message to save file in permanent storage" "AMQP"
        netflixSystem.multimediaApi -> netflixSystem.tempS3storage "Reads"

        // netflixSystem.multimediaApi -> netflixSystem.generalBroker "Sends message to save file" "AMQP"
        // netflixSystem.generalApi -> netflixSystem.tempS3Api "Sends request to save file" "HTTP"
        netflixSystem.generalApi -> netflixSystem.tempS3storage "Reads and writes to" "TCP" 

        netflixSystem.generalBroker -> netflixSystem.permS3Api "Sends message to save file in permanent storage" "AMQP"
        netflixSystem.permS3Api -> netflixSystem.generalBroker "Sends message about successful upload" "AMQP"
        netflixSystem.permS3Api -> netflixSystem.permS3storage "Reads and writes to" "TCP" 

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