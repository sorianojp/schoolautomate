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
</style>
</head>
<body>
<%@ page language="java" import="utility.*,purchasing.Endorsement,purchasing.Requisition,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;	

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-ENDORSEMENT"),"0"));
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
								"Admin/staff-PURCHASING-ENDORSEMENT-Endorsement details","endorsement_dtls_view_print.jsp");
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

	Endorsement EN = new Endorsement();
	Requisition REQ = new Requisition();		
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vReqItems = null;
	Vector vReqItemsEn = null;	
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	int iLoop = 0;
	int iCount = 0;

	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);

	if(vReqInfo != null){
		vRetResult = EN.operateOnNonPOItemsEn(dbOP,request,4,(String)vReqInfo.elementAt(0));
		if(vRetResult == null)
			strErrMsg = EN.getErrMsg();
		else{
			vReqItems = (Vector)vRetResult.elementAt(0);
			vReqItemsEn = (Vector)vRetResult.elementAt(1);				
			//System.out.println("vReqItems " + vReqItems);
		}			
%>
  <table width="50%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="50%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>  
  <table width="50%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(12)%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Request Type</font></td>
      <td width="26%"><font size="1"><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></font></td>
      <td width="20%"><font size="1">Purpose/Job</font></td>
      <td width="31%"><strong><font size="1"><%=(String)vReqInfo.elementAt(5)%></font></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Requisition Status</font></td>
      <td><strong><font size="1"><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></font></strong></td>
      <td><font size="1">Requisition Date</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(7)%></font></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(3)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%}%>
  </table>
  <%if(vReqItems != null && vReqItems.size() > 3){%>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST 
          OF PO ITEM(S)</strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="20" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS / DESCRIPTION</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>RECEIVE STATUS</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>UNIT PRICE </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>TOTAL PRICE </strong></div></td>
    </tr>
    <%for(iLoop = 1,iCount = 1;iLoop < vReqItems.size();iLoop += 9,++iCount){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=vReqItems.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+8),"(",")","")%></div></td>
      <td class="thinborder"><div align="left"><%=astrReceiveStat[Integer.parseInt((String)vReqItems.elementAt(iLoop+5))]%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(vReqItems.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(vReqItems.elementAt(iLoop+7),"&nbsp;")%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="18" colspan="3" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount-1%></strong><input type="hidden" name="numOfItems" value="<%=iCount-1%>"></div>      </td>
      <td colspan="2" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td class="thinborder"><div align="right"><strong><%=WI.getStrValue(vReqItems.elementAt(0),"&nbsp;")%></strong></div></td>
    </tr>
  </table>
  <%}if(vReqItemsEn != null && vReqItemsEn.size() > 3){%> 
  <br>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST 
          OF PO ITEM(S) ENDORSED</strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="20" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="29%" class="thinborder"><div align="center"><strong>ITEM / PARTICULARS /  
          DESCRIPTION </strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>RECEIVE 
          STATUS</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong> 
          UNIT PRICE</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>TOTAL 
          PRICE</strong></div></td>
    </tr>
    <%for(iLoop = 1,iCount = 1;iLoop < vReqItemsEn.size();iLoop+=9,++iCount){%>
    <tr> 
      <td height="26" class="thinborder"><div align="center"><%=vReqItemsEn.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsEn.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItemsEn.elementAt(iLoop+3)%> / <%=vReqItemsEn.elementAt(iLoop+4)%><%=WI.getStrValue((String)vReqItemsEn.elementAt(iLoop+8),"(",")","")%></div></td>
      <td class="thinborder"><div align="left"><%=astrReceiveStat[Integer.parseInt((String)vReqItemsEn.elementAt(iLoop+5))]%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(vReqItemsEn.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue(vReqItemsEn.elementAt(iLoop+7),"&nbsp;")%></div></td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="3" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : &nbsp;&nbsp;<%=iCount-1%></strong></div></td>
      <td  height="25" colspan="2" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td class="thinborder"><div align="right"><strong><%=WI.getStrValue(vReqItemsEn.elementAt(0),"&nbsp;")%></strong></div></td>
    </tr>
  </table>
  <%}%>
  <table width="50%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
	<tr> 
      <td height="24"><div align="center">Received by:___________________________</div></td>
    </tr>
	<tr> 
      <td height="15"><div align="center">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Signature</div></td>
    </tr>
  </table>
<script language="JavaScript">
	window.print();
</script>
<%}else{%>
<script language="JavaScript">
	alert("Please re enter a correct PO number");
</script>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
