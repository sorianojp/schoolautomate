<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderALL {
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-REQUISITION-Requisition Print","req_item_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Requisition REQ = new Requisition();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strTemp = null;
	int iLoop = 2;
	int iCountRows = 0;
	double dTotalAmount = 0d;
	String strSchCode = dbOP.getSchoolIndex();	
	int iNumRows = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rows"),"15"));
	boolean bolShowPresident = false;
			
	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);	
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else{
		if(((String)vReqInfo.elementAt(3)).equals("0")){
		  if ((WI.getStrValue((String)vReqInfo.elementAt(9),"").toLowerCase()).equals("office of the president")){
			bolShowPresident = true;
		  }
		}
	}
	
	vReqItems = REQ.operateOnReqItems(dbOP,request,4);
	if(vReqItems != null)
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;
%>
<form name="form_" method="post">
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <%if(!strSchCode.startsWith("UI")){%>
	 <%if(!strSchCode.startsWith("CLDH")){%>
     <tr> 
      <td align="center" width="27%"><div align="right">&nbsp;
	  <%if(strSchCode.startsWith("CPU")){%>
	  <img src="../../../images/logo/CPU.gif" width="70" height="70" border="0">
	  <%}%>
	  </div></td>
      <td width="46%" height="25" align="center"><div align="left">&nbsp;</div>
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br> 
		<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br> <br> 
		<%if(WI.fillTextValue("is_canvass").length() < 1){%> 
		<font size="+2"><strong>REQUISITION FORM</strong></font> 
        <%}else{%> <font size="+2"><strong>CANVASS FORM</strong></font> 
        <%}%> <br> <br> </td>
      <td width="27%" align="center">&nbsp;</td>
     </tr>
	 <%}// end if not CLDH%>
   <%}else{%>
    <tr> 
      <td height="25" colspan="3">&nbsp;<br> <br> <br> <br> <br></td>
    </tr>
   <%}// if the school code starts with UI %>
  </table>
  <%if(strSchCode.startsWith("CLDH")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="9%" rowspan="2" align="center" valign="top"><div align="left"><img src="../../../images/logo/CLDH.gif" width="70" height="70" border="0"></div></td>
        <td width="66%" rowspan="2" valign="top"> <strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br></td>
        <td height="25" colspan="3" valign="top"><DIV align="center">
          <table width="98%" border="0" cellspacing="0" cellpadding="0" class="thinborderALL">
            <tr>
              <td class="thinborderALL"><div align="center"><strong><font face="Arial, Verdana,  Helvetica, sans-serif" size="2">PURCHASE REQUISITION </font></strong></div></td>
            </tr>
          </table>
        </div></td>
      </tr>      
      <tr>
        <td width="7%" valign="top">&nbsp;</td>
        <td width="7%" height="22"><div align="right"><font size="+1">No.</font>&nbsp;&nbsp;</div></td>
        <td width="11%" valign="bottom" class="thinborderBottom"><strong><font size="1">&nbsp;<%=WI.fillTextValue("req_no")%></font></strong></td>
      </tr>
      <tr>
        <td colspan="3" align="center" valign="top">
		  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
          <tr>
            <td width="18%" class="thinborder"><div align="right">Requisitioning<br>
            Department </div></td>
			<%if(((String)vReqInfo.elementAt(3)).equals("0"))
				strTemp = (String)vReqInfo.elementAt(9);
			  else
				strTemp = (String)vReqInfo.elementAt(8)+ "/" +WI.getStrValue((String)vReqInfo.elementAt(9),"All");
			%>			
            <td width="28%" class="thinborder">&nbsp;<%=strTemp%></td>
            <td width="18%" class="thinborder">Attention: <br>
            Purchasing Dept . </td>
            <td width="36%" class="thinborder"><span class="thinborder">Please purchase for our department the items enumerated below </span></td>
          </tr>
        </table></td>

        <td height="25"><div align="right">Date :&nbsp;&nbsp;</div></td>
        <td valign="bottom" class="thinborderBottom"><strong><font size="1">&nbsp;<%=(String)vReqInfo.elementAt(7)%></font></strong></td>
      </tr>
  </table>
  <%}%>
 <%if(!strSchCode.startsWith("CLDH") && !strSchCode.startsWith("AUF")){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(WI.fillTextValue("is_canvass").length() < 1){%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("req_no")%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td width="2%" height="17">&nbsp;</td>
      <td width="18%"><font size="1">Request Type</font></td>
      <td width="31%"><font size="1"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></font></td>
      <td width="15%"><font size="1">Purpose/Job</font></td>
      <td width="34%"><strong><font size="1"><%=(String)vReqInfo.elementAt(5)%></font></strong></td>
    </tr>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Requisition Status</font></td>
      <td><strong><font size="1"><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></font></strong></td>
      <td><font size="1">Requisition Date</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(7)%></font></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%} // end if  (((String)vReqInfo.elementAt(3)).equals("0"))
	}else{%>
	<tr> 
      <td height="17">&nbsp;</td>
      <td><font size="1">Canvassing No. </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_no")%></font></strong></td>
      <td><font size="1">Canvassing Date </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_date")%></font></strong></td>
    </tr>
	<%}// end if(WI.fillTextValue("is_canvass").length() < 1)%>
  </table>
  <%}// end if not CLDH%>
  <%if(vReqItems != null){%>
  <br>

  <%if(strSchCode.startsWith("CLDH")) {%>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	<tr>
      <td  height="17" colspan="10" class="thinborder"><div align="center"><strong>LIST OF REQUESTED ITEMS</strong></div></td>
	</tr> 
    <tr> 
      <td width="4%" height="17" align="center" class="thinborder"><strong>ITEM #</strong></td>
      <td width="35%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/DESCRIPTION </strong></td>
      <td width="7%" align="center" class="thinborder"><strong>DATE NEEDED </strong></td>
      <td width="6%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=9,++iCountRows){%>
    <tr> 
      <td  height="17" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%> </td>
      <td class="thinborder">&nbsp; </td>
      <td class="thinborder"><div align="left">
        <div align="right"><%=vReqItems.elementAt(iLoop+1)%>&nbsp;</div>
      </div></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <td class="thinborder">&nbsp;</td>
	  <%if(vReqItems.elementAt(iLoop+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(iLoop+7));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
	
    <tr> 
      <td  height="50" colspan="3"><div align="left">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="50%" class="thinborderLeft"><strong>Prepared by </strong></td>
            <td width="50%" class="thinborderLeft"><strong>Approved by </strong></td>
            </tr>
          <tr>
            <td height="19" class="thinborderLeft">&nbsp;</td>
            <td align="center" valign="bottom" class="thinborder">&nbsp; <strong>
              <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
              <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(14),"").toUpperCase()%></font>
              <%}else{%>
              <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(13),"").toUpperCase()%></font>
              <%}%>
            </strong></td>
          </tr>
          <tr>
            <td height="19" class="thinborder">&nbsp;</td>
            <td align="center" class="thinborder">Dept Head </td>
          </tr>
        </table>
      </div></td>
      <td colspan="2" class="thinborder"><strong>TOTALS</strong></td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">======</td>
      <td class="thinborder">&nbsp;</td>
      <td align="center" class="thinborder">======</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>  
	  <%}else if(strSchCode.startsWith("AUF")) {%>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	<tr>
      <td  height="17" colspan="5" class="thinborder"><div align="center"><strong>LIST OF REQUESTED ITEMS</strong></div></td>
	</tr> 
    <tr> 
      <td width="4%" height="17" align="center" class="thinborder">&nbsp;</td>
      <td width="35%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/DESCRIPTION </strong></td>
      <td width="6%" align="center" class="thinborder"><strong>AVAILABLE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>NOT AVAILABLE</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>REMARKS</strong></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=9,++iCountRows){%>
    <tr> 
      <td  height="17" align="right" class="thinborder"><%=vReqItems.elementAt(iLoop+1)%>
        <%=vReqItems.elementAt(iLoop+2)%> </td>
      <td class="thinborder">&nbsp;<%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%> </td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
	  <%if(vReqItems.elementAt(iLoop+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(iLoop+7));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
  </table>  	
  <table width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr>
      <td width="26%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="52%">To be filled up by requester </td>
          </tr>
        <tr>
          <td>Purpose: <strong><font size="1"><%=(String)vReqInfo.elementAt(5)%></font></strong></td>
          </tr>
        <tr>
          <td>&nbsp;</td>
          </tr>
        <tr>
          <td>Date Needed : <strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
          </tr>
        <tr>
          <td>Prepared by: </td>
        </tr>
      </table></td>
      <td width="26%"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="48%">To be filled up by Purchasing and Supply Office </td>
        </tr>
        <tr>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
        </tr>
      </table></td>
    </tr>
  </table>
  <%} else {%>
  <table width="100%" border="0" class="thinborder" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	  <%if(WI.fillTextValue("is_supply").equals("0")){%>
	  <tr>
      <td  height="17" colspan="7" align="center" class="thinborder"><strong>LIST 
          OF REQUESTED ITEMS</strong></td>
	  </tr> 
	  <%}else{%>
	  <tr>
	  <td height="17" colspan="7" align="center" class="thinborder"><strong>LIST 
         OF REQUESTED SUPPLIES</strong></td>
	  </tr>  	  
	  <%}%>    
    <tr> 
      <td width="5%" height="17" align="center" class="thinborder"><strong>ITEM #</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="10%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="35%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/DESCRIPTION </strong></td>
      <td width="17%" align="center" class="thinborder"><strong>SUPPLIER</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>UNIT PRICE</strong></td>
      <td width="13%" align="center" class="thinborder"><strong>AMOUNT</strong></td>
    </tr>
    <% //System.out.println(iNumRows);	
		//System.out.println(vReqItems.size()/9);	
	for(;iLoop < vReqItems.size() && iCountRows < iNumRows;iLoop+=9,++iCountRows){%>
    <tr> 
      <td  height="17" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder"><div align="right"><%=vReqItems.elementAt(iLoop+1)%>&nbsp;</div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%>
	  </div></td>
      <td class="thinborder"><div align="left">&nbsp;<%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborder"><div align="right">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
	  <%if(vReqItems.elementAt(iLoop+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(iLoop+7));%>
    </tr>
    <%}for(;iCountRows < iNumRows;++iCountRows){%>
    <tr> 
      <td height="17" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
	<tr> 
      <td height="17" colspan="5" class="thinborder">&nbsp;</td>
      <td align="right" class="thinborder"><strong>PAGE 
        AMOUNT : </strong></td>
      <td class="thinborder"><div align="right"><strong>
	  <%if(dTotalAmount > 0d){%>
	  <%=CommonUtil.formatFloat(dTotalAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong></div>	  </td>
    </tr>
    <tr> 
      <td  height="17" colspan="5" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.elementAt(0)%></strong></div></td>
      <td align="right" class="thinborder"><strong>TOTAL 
        AMOUNT : </strong></td>
      <td class="thinborder"><div align="right"><strong><%=vReqItems.elementAt(1)%></strong></div></td>
    </tr>
  </table>
	<%}// end else%>	
  <%if(strSchCode.startsWith("CPU")){%>
	<%if(WI.fillTextValue("is_canvass").length() < 1){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="16%" height="22" valign="bottom">Acct. No.:</td>
      <td width="27%" class="thinborderBottom">&nbsp;</td>
      <td width="4%">&nbsp;</td>
      <td width="20%" valign="bottom">Requested by:</td>
      <td width="31%" valign="bottom" class="thinborderBottom"><div align="center"><strong><%=(String)vReqInfo.elementAt(2)%></strong></font></div></td>
      <td width="2%" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="32" valign="bottom">Funds Available:</td>
      <td valign="bottom" class="thinborderBottom">&nbsp;</td>
      <td valign="bottom">&nbsp;</td>
      <td valign="bottom">Recommending Approval:</td>
      <td valign="bottom" class="thinborderBottom"><div align="center">&nbsp; 
          <strong>
          <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
          <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(14),"").toUpperCase()%></font> 
          <%}else{%>
          <font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(13),"").toUpperCase()%></font> 
          <%}%>
          </strong> </div></td>
      <td valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="32" rowspan="2" valign="bottom">Approved:</td>
      <td rowspan="2" valign="bottom" class="thinborderBottom"><div align="center">&nbsp;<strong>
	  <%if(bolShowPresident){%>
	  <%=WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"University President",7)),"").toUpperCase()%>
	  <%}%>	  
	  </strong></div></td>
      <td rowspan="2" valign="bottom">&nbsp;</td>
      <td rowspan="2" valign="bottom">Purchasing Officer:</td>
      <td align="center" valign="top"><font size="1">Unit 
        Head </font></td>
      <td rowspan="2" align="center" valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td align="center" valign="bottom" class="thinborderBottom"><font size="1"><strong><%=WI.formatName((String)vReqInfo.elementAt(16), (String)vReqInfo.elementAt(17),
							(String)vReqInfo.elementAt(18), 7).toUpperCase()%>&nbsp;</strong></font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td align="center" valign="top"><font size="1">President</font></td>
      <td align="center" valign="top">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <%}else{// END IF IS CANVASS < 1%>    
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="18%" height="43" valign="bottom"><strong>CANVASSED BY : </strong></td>
      <td width="29%" class="thinborderBottom">&nbsp;</td>
      <td width="53%">&nbsp;</td>
    </tr>
  </table>
  <%}%>  
  <%}%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22">&nbsp;</td>
    </tr>
  </table>
	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
	
    } // if(vReqItems != null)%
	%>
  <%} // if(vReqInfo != null)  	
	}// outermost for loop%>
	<input type="hidden" name="num_rows" value="<%=WI.fillTextValue("num_rows")%>">
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>