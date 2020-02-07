class PopularEventModel {
  String status;
  String desc;
  List<Data> data;

  PopularEventModel({this.status, this.desc, this.data});

  PopularEventModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    desc = json['desc'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['desc'] = this.desc;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String id;
  String name;
  String isGoing;
  String address;
  String isPrivate;
  String ticketTypeID;
  String picture;
  String pictureTimeline;
  String pictureSmall;
  String dateStart;
  String dateEnd;
  String description;
  String category;
  String status;
  String isHybridEvent;
  Ticket ticket;
  TicketType ticketType;

  Data(
      {this.id,
      this.name,
      this.isGoing,
      this.address,
      this.isPrivate,
      this.ticketTypeID,
      this.picture,
      this.pictureTimeline,
      this.pictureSmall,
      this.dateStart,
      this.dateEnd,
      this.description,
      this.category,
      this.status,
      this.isHybridEvent,
      this.ticket,
      this.ticketType});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    isGoing = json['isGoing'];
    address = json['address'];
    isPrivate = json['isPrivate'];
    ticketTypeID = json['ticketTypeID'];
    picture = json['picture'];
    pictureTimeline = json['picture_timeline'];
    pictureSmall = json['picture_small'];
    dateStart = json['dateStart'];
    dateEnd = json['dateEnd'];
    description = json['description'];
    category = json['category'];
    status = json['status'];
    isHybridEvent = json['isHybridEvent'];
    ticket =
        json['ticket'] != null ? new Ticket.fromJson(json['ticket']) : null;
    ticketType = json['ticket_type'] != null
        ? new TicketType.fromJson(json['ticket_type'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['isGoing'] = this.isGoing;
    data['address'] = this.address;
    data['isPrivate'] = this.isPrivate;
    data['ticketTypeID'] = this.ticketTypeID;
    data['picture'] = this.picture;
    data['picture_timeline'] = this.pictureTimeline;
    data['picture_small'] = this.pictureSmall;
    data['dateStart'] = this.dateStart;
    data['dateEnd'] = this.dateEnd;
    data['description'] = this.description;
    data['category'] = this.category;
    data['status'] = this.status;
    data['isHybridEvent'] = this.isHybridEvent;
    if (this.ticket != null) {
      data['ticket'] = this.ticket.toJson();
    }
    if (this.ticketType != null) {
      data['ticket_type'] = this.ticketType.toJson();
    }
    return data;
  }
}

class Ticket {
  String salesStatus;
  String availableTicketStatus;
  String cheapestTicket;
  String salesStartDate;
  String salesEndDate;

  Ticket(
      {this.salesStatus,
      this.availableTicketStatus,
      this.cheapestTicket,
      this.salesStartDate,
      this.salesEndDate});

  Ticket.fromJson(Map<String, dynamic> json) {
    salesStatus = json['salesStatus'];
    availableTicketStatus = json['availableTicketStatus'];
    cheapestTicket = json['cheapestTicket'];
    salesStartDate = json['sales_start_date'];
    salesEndDate = json['sales_end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['salesStatus'] = this.salesStatus;
    data['availableTicketStatus'] = this.availableTicketStatus;
    data['cheapestTicket'] = this.cheapestTicket;
    data['sales_start_date'] = this.salesStartDate;
    data['sales_end_date'] = this.salesEndDate;
    return data;
  }
}

class TicketType {
  String id;
  String name;
  String type;
  Null paidTicketTypeId;
  String isSetupTicket;
  String isHide;
  String icon;
  String orderNumber;
  String description;

  TicketType(
      {this.id,
      this.name,
      this.type,
      this.paidTicketTypeId,
      this.isSetupTicket,
      this.isHide,
      this.icon,
      this.orderNumber,
      this.description});

  TicketType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    paidTicketTypeId = json['paid_ticket_type_id'];
    isSetupTicket = json['isSetupTicket'];
    isHide = json['isHide'];
    icon = json['icon'];
    orderNumber = json['orderNumber'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['paid_ticket_type_id'] = this.paidTicketTypeId;
    data['isSetupTicket'] = this.isSetupTicket;
    data['isHide'] = this.isHide;
    data['icon'] = this.icon;
    data['orderNumber'] = this.orderNumber;
    data['description'] = this.description;
    return data;
  }
}