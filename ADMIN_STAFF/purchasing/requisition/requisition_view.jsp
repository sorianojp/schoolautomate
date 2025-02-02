<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function CloseWindow(){
	self.close();
}
</script>
<%@ page language="java" import="utility.*,purchasing.Requisition,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;	
	String strErrMsg = null;

	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="req_item_print.jsp"/>
	<%return;}

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-REQUISITION"),"0"));
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
								"Admin/staff-PURCHASING-REQUISITION-Requisition View","requisition_view.jsp");
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
			
	vReqInfo = REQ.operateOnReqInfo(dbOP,request,3);
	if(vReqInfo == null)
		strErrMsg = REQ.getErrMsg();
	else{
		vReqItems = REQ.operateOnReqItems(dbOP,request,4);
		if(vReqItems == null)
			strErrMsg = REQ.getErrMsg();
	}	
	
	
%>
<body bgcolor="#D2AE72">
<form name="form_" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          REQUISITION - SEARCH VIEW DETAIL PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">
	  <a href="javascript:CloseWindow();">	  
	  <img src="../../../images/close_window.gif" border="0" align="right"></a></td>
    </tr>
  </table>
<%
if(vReqInfo != null && vReqInfo.size() > 0){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS </strong></div></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%">Requisition No. :</td>
      <td width="28%"><strong><%=WI.fillTextValue("req_no")%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"> <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(1))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=(String)vReqInfo.elementAt(5)%></strong></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(10))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(7)%></strong></td>
    </tr>
	<%if(((String)vReqInfo.elementAt(3)).equals("0")){%> 
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Office :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)+"/"+WI.getStrValue((String)vReqInfo.elementAt(9),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(6),"&nbsp;")%></strong></td>
    </tr>
	<%}%>	
  </table>  
  <%if(vReqItems != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">  
	  <br>  
      <%if(WI.fillTextValue("is_supply").equals("0")){%>
	  <tr>
      	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED ITEMS</strong></font></div></td>
	  </tr>
	  <%}else{%>
	  <tr>
	  	  <td width="100%" height="25" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF REQUESTED SUPPLIES</strong></font></div></td>
	  </tr>	  
	  <%}%>    
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="27" colspan="8" class="thinborder">Requested by : <strong><%=(String)vReqInfo.elementAt(2)%></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25" class="thinborder"><div align="center"><strong>ITEM#</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>QUANTITY</strong></div></td>
      <td width="8%" class="thinborder"><div align="center"><strong>UNIT</strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong>ITEM</strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong>PARTICULARS/ITEM 
          DESCRIPTION </strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>SUPPLIER</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>UNIT PRICE</strong></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong>AMOUNT</strong></div></td>
    </tr>
    <%for(int iLoop = 2;iLoop < vReqItems.size();iLoop+=9){%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><%=(iLoop+7)/9%></div></td>
      <td class="thinborder"><div align="center"><%=(String)vReqItems.elementAt(iLoop+1)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+2)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+3)%></div></td>
      <td class="thinborder"><div align="left"><%=(String)vReqItems.elementAt(iLoop+4)%></div></td>
      <td class="thinborder"><div align="left"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+5),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right"><%=WI.getStrValue((String)vReqItems.elementAt(iLoop+6),"&nbsp;")%></div></td>
      <td class="thinborder"><div align="right">
	  	<%if(vReqItems.elementAt(iLoop+7) == null || ((String)vReqItems.elementAt(iLoop+7)).equals("0")){%>
	 		&nbsp;
		<%}else{%>
			<%=CommonUtil.formatFloat((String)vReqItems.elementAt(iLoop+7),true)%>
		<%}%></div></td>
    <%}%>
    <tr> 
      <td height="25" colspan="5" class="thinborder"><div align="left"><strong>TOTAL 
          ITEM(S) : <%=(String)vReqItems.elementAt(0)%></strong></div></td>
      <td height="25" colspan="2" class="thinborder"><div align="right"><strong>TOTAL 
          AMOUNT : </strong></div></td>
      <td height="25" class="thinborder"><div align="right"><strong><%=(String)vReqItems.elementAt(1)%></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="center">
	  <a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
	  <font size="1">click to print Items per page</font>
          <select name="num_rows">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
	  
	  </div></td>
    </tr>
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<%}%>
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
