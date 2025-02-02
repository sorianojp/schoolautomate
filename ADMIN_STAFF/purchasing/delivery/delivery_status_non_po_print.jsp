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
	String strSchCode = dbOP.getSchoolIndex();	
	int iLoop1 = 0;
	int iLoop2 = 0;
	int iLoop3 = 0;	
	int iCountRows = 0;
	
	vReqInfo = DEL.operateOnNonPOReqInfo(dbOP,request);	
	if(vReqInfo == null)
		strErrMsg = DEL.getErrMsg();
	else{
		vRetResult = DEL.operateOnNonPOItemsDel(dbOP,request,4,(String)vReqInfo.elementAt(0),strSchCode,false);
		if(vRetResult == null)
			strErrMsg = DEL.getErrMsg();
		else{
			vReqPO = (Vector)vRetResult.elementAt(0);
			vReqItems = (Vector)vRetResult.elementAt(1);
			vReturned = (Vector)vRetResult.elementAt(2);
		}	
	}
	if(vRetResult != null)// depensa sa null pointer sa mga tanga na user
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
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(12)%></font></strong></td>
      <td><font size="1">Requested By</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(2)%></font></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="20%"><font size="1">Requisition Date</font></td>
      <td width="26%"><strong><font size="1"><%=(String)vReqInfo.elementAt(7)%></font></strong></td>
      <td width="20%"><font size="1">Purpose/Job</font></td>
      <td width="31%"><strong><font size="1"><%=(String)vReqInfo.elementAt(5)%></font></strong></td>
    </tr>
    
	<%if(((String)vReqInfo.elementAt(3)) == null){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Office</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(9),"")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(8),"")+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%>
	  </font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
	<%}%>
  </table>
  <br>
  <%if(vReqPO != null && vReqPO.size() > 0 && iLoop1 < vReqPO.size()){%>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="4" class="thinborder"><div align="center"><strong>LIST OF PO ITEM(S) NOT DELIVERED</strong></font>
	  </div></td>
    </tr>
    <tr> 
      <td width="10%" height="25" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="28%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/ITEM DESCRIPTION </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>RECEIVE STATUS</strong></div></td>
    </tr>
    <%for(;iLoop1 < vReqPO.size() && iCountRows < 15;iLoop1+=10,++iCount,++iCountRows){%>
    <tr> 
      <td height="26" class="thinborder"><div align="center"><%=(String)vReqPO.elementAt(iLoop1+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqPO.elementAt(iLoop1+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqPO.elementAt(iLoop1+3)%>/<%=(String)vReqPO.elementAt(iLoop1+4)%><%=WI.getStrValue((String)vReqPO.elementAt(iLoop1+7),"(",")","")%></div>
	  </td>
      <td class="thinborder"><div align="left"><%=astrReceiveStat[Integer.parseInt((String)vReqPO.elementAt(iLoop1+6))]%> &nbsp;
	  </div></td>
    </tr>
    <%}%>
	<%for(;iCountRows < 15;++iCountRows){%>
    <tr> 
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount -1%></strong></div></td>
    </tr>
  </table>
  <br>
  <%}if(vReqItems != null && vReqItems.size() > 0 && vReqPO != null && iLoop1 >= vReqPO.size() && iCountRows < 15){%>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="5" class="thinborder"><div align="center"><strong>LIST 
          OF PO ITEM(S) DELIVERED</strong></div></td>
    </tr>
    <tr> 
      <td width="8%" height="25" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/ITEM DESCRIPTION </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>RECEIVE STATUS</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>DATE RECEIVED</strong></div></td>
    </tr>
    <%iCount = 1;
	for(;iLoop2 < vReqItems.size() && iCountRows < 15;iLoop2+=12,++iCount,++iCountRows){%>
    <tr> 
      <td height="26" class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop2+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop2+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop2+3)%>/<%=(String)vReqItems.elementAt(iLoop2+4)%><%=WI.getStrValue((String)vReqItems.elementAt(iLoop2+9),"(",")","")%> </div></td>
      <td class="thinborder"><div align="left"><%=astrReceiveStat[Integer.parseInt((String)vReqItems.elementAt(iLoop2+6))]%></div>
	  </td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop2+7)%></div></td>
    </tr>
    <%}for(;iCountRows < 15;++iCountRows){%>
    <tr> 
      <td height="26" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%></strong></div></td>
    </tr>
  </table>
  <br>
  <%} iCountRows = 0;  
  if(vReturned != null && vReturned.size() > 0 && vReqPO != null && iLoop1 >= vReqPO.size() 
     && vReqItems != null && iLoop2 >= vReqItems.size()){
  %>
  <table width="50%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td  height="25" colspan="4" class="thinborder"><div align="center"><strong>LIST 
          OF PO ITEM(S) RETURNED</strong></div></td>
    </tr>
    <tr> 
      <td width="8%" height="25" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="26%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/ITEM 
          DESCRIPTION </strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>RECEIVE STATUS</strong></div></td>
    </tr>
    <%iCount = 1;	
	for(;iLoop3 < vReturned.size() && iCountRows < 15;iLoop3+=10,++iCount,++iCountRows){	
	%>
    <tr> 
      <td height="26" class="thinborder"><div align="center"><%=(String)vReturned.elementAt(iLoop3+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReturned.elementAt(iLoop3+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReturned.elementAt(iLoop3+3)%>/<%=(String)vReturned.elementAt(iLoop3+4)%><%=WI.getStrValue((String)vReturned.elementAt(iLoop3+11),"(",")","")%> </div></td>
      <td class="thinborder"><div align="left"><%=astrReceiveStat[Integer.parseInt((String)vReturned.elementAt(iLoop3+6))]%></div></td>
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
      <td height="25" colspan="4" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=iCount - 1%></strong></div></td>
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
