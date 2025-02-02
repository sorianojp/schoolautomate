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
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Purchasing-Purchasing","req_item_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Purchasing","Purchasing",request.getRemoteAddr(),
														"req_item_print.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

	Requisition REQ = new Requisition();	
	Vector vReqInfo = null;
	Vector vReqItems = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};	
	int iLoop = 2;
	int iCountRows = 0;
	double dTotalAmount = 0d;
			
	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();				
	
	vReqItems = REQ.operateOnReqItems(dbOP,request,4);
	if(vReqItems == null)
		strErrMsg = REQ.getErrMsg();
	for(;iLoop < vReqItems.size();){
		iCountRows = 0;
		dTotalAmount = 0d;
%>
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vReqInfo != null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">        
	<tr> 
    <td height="25" colspan="2"><div align="center"> 
            <%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br>
        </div></td>
  </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<%if(WI.fillTextValue("is_canvass").length() < 1){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Requisition No.</font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("req_no")%></font></strong></td>
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
    <%if(((String)vReqInfo.elementAt(3)).equals("0")){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Non-Acad. Office/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(9)%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">College/Dept</font></td>
      <td><strong><font size="1"><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></font></strong></td>
      <td><font size="1">Date Needed</font></td>
      <td><strong><font size="1"><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></font></strong></td>
    </tr>
    <%}
	}else{%>
	<tr> 
      <td height="26">&nbsp;</td>
      <td><font size="1">Canvassing No. </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_no")%></font></strong></td>
      <td><font size="1">Canvassing Date </font></td>
      <td><strong><font size="1"><%=WI.fillTextValue("canvass_date")%></font></strong></td>
    </tr>
	<%}%>
  </table>
  <%if(vReqItems != null){%>
  <br>
  <table width="100%" border="0" class="thinborder" cellpadding="1" cellspacing="1" bgcolor="#FFFFFF">    
	  <%if(WI.fillTextValue("is_supply").equals("0")){%>
	  <tr>
      <td  height="25" colspan="7" class="thinborder"><div align="center"><strong>LIST 
          OF REQUESTED ITEMS</strong></div></td>
	  </tr> 
	  <%}else{%>
	  <tr>
	  <td height="25" colspan="7" class="thinborder"><div align="center"><strong>LIST 
         OF REQUESTED SUPPLIES</strong></div></td>
	  </tr>  	  
	  <%}%>    
    <tr> 
      <td width="5%" height="25" class="thinborder"><div align="center"><strong>ITEM #</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>QTY</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="35%" class="thinborder"><div align="center"><strong>ITEM/PARTICULARS/DESCRIPTION </strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>SUPPLIER</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%for(;iLoop < vReqItems.size() && iCountRows < 15;iLoop+=9,++iCountRows){%>
    <tr> 
      <td  height="25" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder"><div align="center"><%=vReqItems.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=vReqItems.elementAt(iLoop+3)%> / <%=vReqItems.elementAt(iLoop+4)%>
	  </div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
	  <%if(vReqItems.elementAt(iLoop+7) != null)
	    	dTotalAmount += Double.parseDouble((String)vReqItems.elementAt(iLoop+7));%>
    </tr>
    <%}for(;iCountRows < 15;++iCountRows){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
    <%}%>
	<tr> 
      <td  height="25" colspan="5" class="thinborder">&nbsp;</td>
      <td  height="25" class="thinborder"><div align="left"><strong>PAGE 
        AMOUNT : </strong></div></td>
      <td  height="25" class="thinborder"><div align="right"><strong>
	  <%if(dTotalAmount > 0d){%>
	  <%=CommonUtil.formatFloat(dTotalAmount,true)%>
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </strong></div>	  </td>
    </tr>
    <tr> 
      <td  height="25" colspan="5" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=vReqItems.elementAt(0)%></strong></div></td>
      <td  height="25" class="thinborder"><div align="left"><strong>TOTAL 
        AMOUNT : </strong></div></td>
      <td  height="25" class="thinborder"><div align="right"><strong><%=vReqItems.elementAt(1)%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
 	<%if (iLoop < vReqItems.size()) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
    }}}%>
</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>