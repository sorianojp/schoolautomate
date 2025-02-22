<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	if(strSchCode.startsWith("SWU")){%>
	<jsp:forward page="./delivery_update_status_SWU_print.jsp"></jsp:forward>
	<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,purchasing.Delivery,java.util.Vector" %>
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery update Status","delivery_update_status_print.jsp");
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
	
	Delivery DEL = new Delivery();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	Vector vReqPO = null;
	Vector vReturned = null;
	Vector vRetResult = null;
	int iCount = 1;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String[] astrReceiveStat = {"Not Received","Received(Status OK)","Received (Status not OK)","Returned"};	
	
	int iLoop1 = 0;
	int iLoop2 = 0;
	int iLoop3 = 0;	
	int iCountRows = 0;
	
	vReqInfo = DEL.operateOnReqInfoDel(dbOP,request);	
	if(vReqInfo == null)
		strErrMsg = DEL.getErrMsg();
	else{
		vRetResult = DEL.operateOnReqItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0),strSchCode);
		if(vRetResult == null)
			strErrMsg = DEL.getErrMsg();
		else{
			vReqPO = (Vector)vRetResult.elementAt(0);
			vReqItems = (Vector)vRetResult.elementAt(1);
			vReturned = (Vector)vRetResult.elementAt(2);
		}	
	}
	for(;iLoop1 < vReqPO.size() || iLoop2 < vReqItems.size() || iLoop3 < vReturned.size(); ){
		iCountRows = 0;
%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font>
	  </strong></td>
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
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(4)%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(5)%></font></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Requisition Date</font></td>
      <td width="26%"><strong><font size="1"><%=(String)vReqInfo.elementAt(9)%></font></strong></td>
      <td width="20%"><font size="1">Purpose/Job</font></td>
      <td width="31%"><strong><font size="1"><%=(String)vReqInfo.elementAt(7)%></font></strong></td>
    </tr>
    
	<%if(((String)vReqInfo.elementAt(10)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(11)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></font></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(10)+"/"+WI.getStrValue((String)vReqInfo.elementAt(11),"All")%>
	  </font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(12),"&nbsp;")%></font></strong></td>
    </tr>
	<%}%>
  </table>
  <br>
  <%if(vReqPO != null && vReqPO.size() > 3 && iLoop1 < vReqPO.size()){%>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="3" align="center" class="thinborder"><strong>LIST OF PO ITEM(S) NOT DELIVERED</strong></font>	  </td>
    </tr>
    <tr> 
      <td width="12%" height="25" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="20%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="68%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/ITEM DESCRIPTION </strong></td>
    </tr>
    <%for(;iLoop1 < vReqPO.size() && iCountRows < 15;iLoop1+=10,++iCount,++iCountRows){%>
    <tr> 
      <td height="26" align="right" class="thinborder"><%=(String)vReqPO.elementAt(iLoop1+8)%></td>
      <td class="thinborder"><%=(String)vReqPO.elementAt(iLoop1+2)%></td>
      <td class="thinborder"><%=(String)vReqPO.elementAt(iLoop1+3)%>/<%=(String)vReqPO.elementAt(iLoop1+4)%><%=WI.getStrValue((String)vReqPO.elementAt(iLoop1+7),"(",")","")%></td>
    </tr>
    <%}%>
	<%for(;iCountRows < 15;++iCountRows){%>
    <tr> 
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount -1%></strong></td>
    </tr>
  </table>
  <br>
  <%}if(vReqItems != null && vReqItems.size() > 3 && vReqPO != null && iLoop1 >= vReqPO.size() && iCountRows < 15){%>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="3" align="center" class="thinborder"><strong>LIST 
        OF PO ITEM(S) DELIVERED</strong></td>
    </tr>
    <tr> 
      <td width="12%" height="25" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="21%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="67%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/ITEM DESCRIPTION </strong></td>
    </tr>
    <%iCount = 1;
	for(;iLoop2 < vReqItems.size() && iCountRows < 15;iLoop2+=14,++iCount,++iCountRows){%>
    <tr> 
      <td height="26" align="right" class="thinborder"><%=(String)vReqItems.elementAt(iLoop2+12)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop2+2)%></td>
      <td class="thinborder"><%=(String)vReqItems.elementAt(iLoop2+3)%>/<%=(String)vReqItems.elementAt(iLoop2+4)%><%=WI.getStrValue((String)vReqItems.elementAt(iLoop2+9),"(",")","")%> </td>
    </tr>
    <%}for(;iCountRows < 15;++iCountRows){%>
    <tr> 
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="3" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%></strong></td>
    </tr>
  </table>
  <br>
  <%} iCountRows = 0;  
  if(vReturned != null && vReturned.size() > 3 && vReqPO != null && iLoop1 >= vReqPO.size() 
     && vReqItems != null && iLoop2 >= vReqItems.size()){
  %>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="4" align="center" class="thinborder"><strong>LIST 
        OF PO ITEM(S) RETURNED</strong></td>
    </tr>
    <tr> 
      <td width="8%" height="25" align="center" class="thinborder"><strong>QTY</strong></td>
      <td width="8%" align="center" class="thinborder"><strong>UNIT</strong></td>
      <td width="26%" align="center" class="thinborder"><strong>ITEM/PARTICULARS/ITEM 
        DESCRIPTION </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>RECEIVE STATUS</strong></td>
    </tr>
    <%iCount = 1;	
	for(;iLoop3 < vReturned.size() && iCountRows < 15;iLoop3+=13,++iCount,++iCountRows){	
	%>
    <tr> 
      <td height="26" align="right" class="thinborder"><%=(String)vReturned.elementAt(iLoop3+1)%></td>
      <td class="thinborder"><%=(String)vReturned.elementAt(iLoop3+2)%></td>
      <td class="thinborder"><%=(String)vReturned.elementAt(iLoop3+3)%>/<%=(String)vReturned.elementAt(iLoop3+4)%><%=WI.getStrValue((String)vReturned.elementAt(iLoop3+11),"(",")","")%> </td>
      <td class="thinborder"><%=astrReceiveStat[Integer.parseInt((String)vReturned.elementAt(iLoop3+6))]%></td>
    </tr>
    <%}for(;iCountRows < 15;++iCountRows){%>
    <tr> 
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%></strong></td>
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
  <%if(iLoop1 < vReqPO.size() || iLoop2 < vReqItems.size() || iLoop3 < vReturned.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }%>
</body>
</html>
<%
dbOP.cleanUP();
%>
