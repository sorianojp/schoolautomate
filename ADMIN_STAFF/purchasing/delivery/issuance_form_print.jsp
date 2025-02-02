<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

<body>
<%@ page language="java" import="utility.*,purchasing.IssuanceMgmt,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
		
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-ISSUANCE","issuance_mgmt.jsp");
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


	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	
	IssuanceMgmt issueMgmt = new IssuanceMgmt();
	Vector vRetResult = null;	
	Vector vIssuanceInfo = null;
	Vector vIssuanceItem = null;
	Vector vPOInfo = null;
	int iElemCount = 0;
	
	boolean bolIsPONumber = false;	
	
	vPOInfo = issueMgmt.getPOIssueInfo(dbOP, request);
	if(vPOInfo == null)	
		strErrMsg = issueMgmt.getErrMsg();
	else{
		vIssuanceInfo = issueMgmt.getIssuanceInfo(dbOP, request, null, WI.fillTextValue("issuance_no"));
		if(vIssuanceInfo != null && vIssuanceInfo.size() > 0)
			vIssuanceInfo.insertElementAt(Integer.toString(issueMgmt.getElemCount()), 0);
	}	
	
	bolIsPONumber = issueMgmt.isPONumber();

if(vPOInfo != null && vPOInfo.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="2" align="center">
		<strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br>
		<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br>
		PROPERTY DEPARTMENT<br><br>
		</td>
	</tr>
	
	<tr>
	<%
	strTemp = "";
	strErrMsg = "";
	if(vIssuanceInfo != null && vIssuanceInfo.size() > 0){
		strTemp = (String)vIssuanceInfo.elementAt(12);//this is +1 bec. i insert element count in top
		strErrMsg = (String)vIssuanceInfo.elementAt(2);
	}
	%>
		<td height="25" width="50%">ISSUANCE DATE : <%=strTemp%></td>
		<td width="50%" align="right">ISSUANCE FORM NUMBER : <%=strErrMsg%></td>
	</tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
	  <%
	  	if(bolIsPONumber)
	  		strTemp = "REQUISITION DETAILS FOR PURCHASE ORDER NO. : ";
		else
			strTemp = "ISSUANCE DETAILS FOR ISSUANCE NO : ";
	  %>
      <td colspan="4" align="center"><strong><%=strTemp%><%=(String)vPOInfo.elementAt(1)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>PO Status:</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vPOInfo.elementAt(3))]%></strong></td>
	  <%
	  	if(bolIsPONumber) strTemp = "PO Date :";
		else strTemp = "Issuance Date :";
	  %>
      <td><%=strTemp%></td>
      <td><strong><%=(String)vPOInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
	  <%
	  	if(bolIsPONumber) strTemp = "Requisition No. :";
		else strTemp = "PO Number :";
	  %>
      <td width="22%"><%=strTemp%></td>
      <td width="28%"><strong><%=(String)vPOInfo.elementAt(4)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vPOInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vPOInfo.elementAt(6))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vPOInfo.elementAt(7)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vPOInfo.elementAt(8))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vPOInfo.elementAt(9)%></strong></td>
    </tr>
    <%if(((String)vPOInfo.elementAt(10)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vPOInfo.elementAt(11)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vPOInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vPOInfo.elementAt(10)+"/"+WI.getStrValue((String)vPOInfo.elementAt(11),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vPOInfo.elementAt(12),"&nbsp;")%></strong></td>
    </tr>
    <%}%>	
  </table>
  
  
  
<%


int iCount = 0;

  
if(vIssuanceInfo != null && vIssuanceInfo.size() > 1){
iElemCount = Integer.parseInt((String)vIssuanceInfo.remove(0));
String strIssuanceNo = null;
String strIssuanceIndex = null;
String strIssuedBy = null;
String strReceivedBy = null;
while(vIssuanceInfo.size() > 0){

	strIssuanceIndex = (String)vIssuanceInfo.remove(0);		
	strIssuanceNo = (String)vIssuanceInfo.remove(0);	
	
	strIssuedBy = WebInterface.formatName((String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),4)+
			WI.getStrValue((String)vIssuanceInfo.remove(0)," (",")","");
	
	//vIssuanceInfo.remove(0);vIssuanceInfo.remove(0);vIssuanceInfo.remove(0);vIssuanceInfo.remove(0);//issued by info
	
	strReceivedBy = WebInterface.formatName((String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),(String)vIssuanceInfo.remove(1),4)+
			WI.getStrValue((String)vIssuanceInfo.remove(0)," (",")","");
	
	//vIssuanceInfo.remove(0);vIssuanceInfo.remove(0);vIssuanceInfo.remove(0);vIssuanceInfo.remove(0);//received by info
	
	
	
	vIssuanceInfo.remove(0);//[10]ISSUANCE_DATE
	vIssuanceInfo.remove(0);//[11]ISSUANCE_DATETIME
	
	vIssuanceItem = issueMgmt.getIssuanceItems(dbOP, request, strIssuanceIndex);
	if(vIssuanceItem == null)
		vIssuanceItem = new Vector();
	else
		iElemCount = issueMgmt.getElemCount();

%>	

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
      <td height="25" colspan="8" align="center" bgcolor="#99CCFF" class="thinborder">
	  	<strong>LIST OF ITEM(S) FOR ISSUANCE NO. : <%=strIssuanceNo%> </strong></td>
    </tr>
    <tr> 
      <td width="4%" height="25" align="center" valign="bottom" class="thinborder"><strong>ITEM#</strong></td>
      
      <td width="10%" align="center" valign="bottom" class="thinborder"><strong>UNIT</strong></td>
      <td align="center" valign="bottom" class="thinborder"><strong>ITEM / PARTICULARS / DESCRIPTION </strong></td>
      <td width="12%" align="center" valign="bottom" class="thinborder"><strong>SUPPLIER CODE </strong></td>
      <td width="13%" align="center" valign="bottom" class="thinborder"><strong>BRAND</strong></td>
	  <td width="10%" align="center" valign="bottom" class="thinborder"><strong>UNIT PRICE</strong></td>
	  <td width="5%" align="center" valign="bottom" class="thinborder"><strong>ISSUE<br>QTY</strong></td>
	  <td width="10%" align="center" valign="bottom" class="thinborder"><strong>UNIT PRICE</strong></td>	 
    </tr>
    <%
	iCount = 0;
	double dAmount = 0d;
	double dTotAmt = 0d;
	for(int i = 0;i < vIssuanceItem.size();i+=iElemCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=++iCount%></div></td>
      <td class="thinborder"><%=WI.getStrValue(vIssuanceItem.elementAt(i+2),"&nbsp;")%></td>
	  <%
	  strTemp = WI.getStrValue(vIssuanceItem.elementAt(i+3))+WI.getStrValue((String)vIssuanceItem.elementAt(i+4)," / ","","");
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vIssuanceItem.elementAt(i+5),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vIssuanceItem.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String)vIssuanceItem.elementAt(i+7),true),"&nbsp;")%></td>
	  <td class="thinborder" align="center"><%=(String)vIssuanceItem.elementAt(i+1)%></td>
	  <%
	  try{
	  dAmount = Double.parseDouble((String)vIssuanceItem.elementAt(i+7)) * Integer.parseInt((String)vIssuanceItem.elementAt(i+1));
	  }catch(NumberFormatException nfe){dAmount = 0;}
	  dTotAmt += dAmount;
	  %>
	  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dAmount,true)%></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><strong>TOTAL ITEM(S) : <%=iCount%>  </strong></td>
      <td height="25" colspan="3" align="right" class="thinborderBOTTOM"><strong>TOTAL AMOUNT : &nbsp;</strong></td>
      <td height="25" colspan="2" align="right" class="thinborderBOTTOMRIGHT"><strong><%=CommonUtil.formatFloat(dTotAmt,true)%></strong></td>
    </tr>
  </table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="12%" height="40" valign="bottom" align="right">Prepared by : &nbsp; </td>
		<td width="35%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"><%=WI.getStrValue(strIssuedBy)%></div></td>
		<td width="18%" align="right" valign="bottom">Prepared by : &nbsp; </td>
		<%
		if(strReceivedBy == null || strReceivedBy.length() == 0)
			strReceivedBy = (String)vPOInfo.elementAt(5);//requested
		%>
		<td width="35%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"><%=WI.getStrValue(strReceivedBy)%></div></td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td>Property Department</td>
	    <td>&nbsp;</td>
	    <td>Requesting Department</td>
    </tr>  	
</table>
<%
}//end of while
}// end if vIssuanceInfo%>
<script>window.print();</script>
<%}%>	


 
</body>
</html>
<%
dbOP.cleanUP();
%>