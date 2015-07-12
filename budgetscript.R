#read transaction statement into R
tab1=read.delim('plat_2014:2015.csv', sep=",",row.names = NULL,header=F)
tab2=read.delim('EO_2014:2015.csv', sep=",",row.names = NULL,header=F)
tab=rbind(tab1,tab2)

#prepare data table
colnames(tab) <- c("date", "value", "desc")
tab=tab[,-4]
tab$date <- as.Date(tab$date, format="%d/%m/%Y")
tab$month <- as.Date(cut(tab$date, breaks="month"))

tab <- subset(tab, tab$value < 0)


# Build simple regexp strings
transport <- "MYKI|CITYLINK|CITY OF|PAY STAY|EASTLINK TOLL|VICROADS"
cabs <-"UBER|BLACK CAB|SILVERTOP|INGOGO"
food <- "COLES|IGA|WOOLWORTHS|YOURGROCER|PIEDIMONTE'S|SAFEWAY|SEAFOOD|PIEDIMONTES"
homewares <- "BUNNINGS|IKEA|HARVEY NORMAN|TEMPLE|STYLISH AFFAIR|JASPER|THOMAS GANNAN|NOTTOOSHABBY|SPOILT|BED BATH N TABLE|DICK SMITH|LOST AND FOUND|OFFICEWORKS|POTS|THEHOME"
chemist <- "CHEMIST|PHARMACY|PHARMAC|CHEM WAREHS"
darcy <- "Vet|SUPERPET|P VALE VET"
medical <- "West Brunswick Clinic|ANGELICA|DENTAL|WHITEH|MelbCityMedicalCentre|IVF|MEDICAL|TMVC|CHIROPRACTIC"
phone_internet <- "VODAFONE|DODO|TELSTRA"
insurance <- "HBF|BUPA|CGU|INSURANCE"
itunes <- "ITUNES"
charity <- "CHILDREN|CHUFFED|GOFUNDRAISE"
bills <- "BPAYN|ENERGY AUSTRALIA|CITY OF YARRA|EnergyAustralia"
fuel <- "PETROL|7-ELEVEN"
tickets <- "TICKET|FESTIV|PORT FAIRY|VICTORIAN ARTS CENTRE|TRYBOOKING.COM"
travel <- "ESCAPE TRAVEL|FLIGHTCENTRE|AIRBNB|QANTAS|ADVANTAGE TRAVEL|ESCAPETRAVELCITY|TRAVELEX"
books <- "AMAZON|Books"
subscriptions <- "DROPBOX"
booze <- "LIQUORLAND|DAN MURPHYS|WINERY|DUTY FREE|BWS|LIQUOR"
clothes <- "MYER|KMART|MOGO|UNIQLO|TARGET|ANTONS|BIG W|CLEAR IT|DANGERFIELD|Emporium"
haircuts <- "URBAN MAN|BARBER|VERTIGO|EUREKA|Hair"
gifts <- "ANGEL FLOWERS|FLOWERS|CHEFS ARMOURY|OUTRE"
dadmin <- "BILLPAY|BEST AND LESS|DYMOCKS|STRATCO|VACUUM|VISY"
eating_out<-"The Post Office Hotel|CURE|Doutta|GREAT NORTHERN|Hofbrauhaus|LITTLE CREATURES|MeatMaiden|MEATWELL|ARBORY|OHEAS|PAYPAL|PENNY BLUE|SPOTTED MALLARD|STAGGER|THE UNION HOTEL|O'HEA'S|COLLINS QUARTER"
penalities <- "FINES VIC"
music <- "RECORDS|GOOGLE"
funmoney <- "Fun Money|Weekly spend"
homeloan <- "Loan Repayment|Home Loan"
memberships<- "eDebit 201175"
withdrawals<-'Wdl'

# Add a class field to the data, default "other"
tab$class <- "Other"

tab$class <- ifelse(grepl(transport, tab$desc), "Transport",
                    ifelse(grepl(cabs, tab$desc), "Cabs",
                    ifelse(grepl(food, tab$desc), "Food",
                    ifelse(grepl(homewares, tab$desc), "Homewares",
                    ifelse(grepl(chemist, tab$desc), "Chemist",
                    ifelse(grepl(darcy, tab$desc), "Darcy",
                    ifelse(grepl(medical, tab$desc), "Medical",
                    ifelse(grepl(phone_internet, tab$desc), "Phone_Interweb",
                    ifelse(grepl(insurance, tab$desc), "Insurance",
                    ifelse(grepl(itunes, tab$desc), "iTunes",
                    ifelse(grepl(charity, tab$desc), "Charity",
                    ifelse(grepl(bills, tab$desc), "Bills",
                    ifelse(grepl(fuel, tab$desc), "Fuel",
                    ifelse(grepl(tickets, tab$desc), "Tickets",
                    ifelse(grepl(travel, tab$desc), "Travel",
                    ifelse(grepl(books, tab$desc), "Books",
                    ifelse(grepl(subscriptions, tab$desc), "Subscriptions",
                    ifelse(grepl(booze, tab$desc), "Booze",
                    ifelse(grepl(clothes, tab$desc), "Clothes",
                    ifelse(grepl(gifts, tab$desc), "Gifts",
                    ifelse(grepl(dadmin, tab$desc), "Dadmin",
                    ifelse(grepl(eating_out, tab$desc), "Eating Out",
                    ifelse(grepl(penalities, tab$desc), "Penalities",
                    ifelse(grepl(music, tab$desc), "Music",
                    ifelse(grepl(funmoney, tab$desc), "WeeklySpend",
                    ifelse(grepl(homeloan, tab$desc), "Mortgage",
                    ifelse(grepl(memberships, tab$desc), "Memberships",
                    ifelse(grepl(withdrawals, tab$desc), "Random Withdraws",
                    ifelse(grepl(haircuts, tab$desc), "Haircuts", "Other")))))))))))))))))))))))))))))

#print table
write.table(tab,file='Expenditure_2014:2015.csv',sep=",",col.names=NA)

#plotting functions
library(ggplot2)
library(plyr)
library(gridExtra)

smr <- ddply(tab, .(month, class), summarise, cost=abs(sum(value)))

#multiplot function
p = ggplot(smr, aes(month, cost, col=class)) +
  facet_wrap(~class, ncol=2, scale="free_y") +
  geom_smooth(method="loess", se=F) + geom_point() +  
  theme(axis.text.x=element_text(angle=45, hjust=1), 
        legend.position="none") + 
  labs(x="", y="Monthly total ($)")

plots = dlply(smr , 'class', `%+%`, e1 = p)
ml = do.call(marrangeGrob, c(plots, list(nrow=4, ncol=2)))
ggsave("monthlytotals_2014:2015.pdf", ml)
dev.off()

#barchart
yl <- ddply(smr, .(class), summarise, m=median(cost))
m2=round(yl$m,0)
pdf('Median by month.pdf',width=10,height=10)
ggplot(yl, aes(x=class, y=m)) + 
  geom_bar(stat="identity") +
  geom_text(aes(label = m2), vjust = -.5, size=4) +
  labs(y="Median monthly expense ($)", x="") +
theme(axis.text.x  = element_text(angle=90, vjust=0.5, size=8))
dev.off()

 


