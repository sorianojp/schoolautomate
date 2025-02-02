<%@ page language="java" import="utility.*,purchasing.Quotation,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);

	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
function CloseWindow(){
	self.close();
}
function ReloadPage(){
	document.form_.printPage.value = "";
	//var selectedIndex = null;
	this.SubmitOnce('form_');
}
function Forward(){	
	location = "canvass_view.jsp?req_no="+document.form_.req_no.value+
						 "&canvass_no="+document.form_.canvass_no.value+
						 "&canvass_date="+document.form_.canvass_date.value+						 
						 "&is_supply="+document.form_.is_supply.value;
}
</script>
<%	
	if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="./canvass_view2_print.jsp"/>
	<%return;}

	DBOperation dbOP = null;	
//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-CANVASSING"),"0"));
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
								"Admin/staff-PURCHASING-CANVASSING-Canvassing View","canvass_view.jsp");
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
	Quotation QTN = new Quotation();	
	Vector vReqInfo = null;
	Vector vRetResult = null;
	Vector vColumns = null;
	Vector vRows = null;
	Vector vRowCols = null;
	String strErrMsg = null;
	String[] astrReqStatus = {"Disapproved","Approved","Pending","Not Required"};	
	String[] astrReqType = {"New","Replacement"};
	String strInfoIndex = WI.fillTextValue("info_index");
	String strTemp  = null;
	String strTemp2 = null;
	String strTemp3 = null;
	int iLoop = 0;
	int iCount = 0;
	boolean bolHasSupplier = false;
	String[] astrSuppliers = new String[5];
	double dTemp = 0d;
	
	int iTemp = 1;
	int j = 0;
	for(iLoop = 0; iLoop < 5; iLoop++){
		strTemp = WI.fillTextValue("supplier"+(iLoop+1));		
		for(j = 1; j < 6;j++){
			strTemp2 = WI.fillTextValue("supplier"+j);
			if(strTemp.equals(strTemp2))
				continue;
				
			if(astrSuppliers[iLoop] == null || astrSuppliers[iLoop].length() == 0)
				astrSuppliers[iLoop] = strTemp2;
			else
				astrSuppliers[iLoop] = astrSuppliers[iLoop] + WI.getStrValue(strTemp2,",","","");
		}
	}
	
	int iDefault = 0;
	String strSchCode = dbOP.getSchoolIndex();
	
		vReqInfo = QTN.operateOnReqInfoQtn(dbOP,request, WI.fillTextValue("canvass_no"));		
		for(int i = 1; i < 6; i++){
			if(WI.fillTextValue("supplier"+i).length() > 0){
				bolHasSupplier = true;
				break;
			}				
		}		
		if(bolHasSupplier){
			vRetResult = QTN.generateQuotationPerSupplier(dbOP,request, WI.fillTextValue("canvass_no"));
			if(vRetResult != null){
				vRows = (Vector)vRetResult.elementAt(0);				
				vColumns = (Vector)vRetResult.elementAt(1);				
			}
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
	<%if(vReqInfo != null && vReqInfo.size() > 2){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D">
      <td width="4%" height="26">&nbsp;</td>
      <td colspan="4"><div align="center"><strong>REQUISITION DETAILS FOR  CANVASS NO : <%=vReqInfo.elementAt(1)%></strong></div></td>
    </tr>		
    <tr>
      <td height="25" width="4%">&nbsp;</td>
      <td width="22%">Requisition No. :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(3)%></strong></td>
      <td width="20%">Requested by :</td>
      <td width="28%"><strong><%=vReqInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Request Type :</td>
      <td><strong><%=astrReqType[Integer.parseInt((String)vReqInfo.elementAt(5))]%></strong></td>
      <td>Purpose/Job :</td>
      <td><strong><%=vReqInfo.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Requisition Status :</td>
      <td><strong><%=astrReqStatus[Integer.parseInt((String)vReqInfo.elementAt(7))]%></strong></td>
      <td>Requisition Date :</td>
      <td><strong><%=(String)vReqInfo.elementAt(8)%></strong></td>
    </tr>
    <%if(((String)vReqInfo.elementAt(9)) == null){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Non-Acad. Office/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(10)%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}else{%>
    <tr>
      <td height="26">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Dept :</td>
      <td><strong><%=(String)vReqInfo.elementAt(9)+"/"+WI.getStrValue((String)vReqInfo.elementAt(10),"All")%></strong></td>
      <td>Date Needed :</td>
      <td><strong><%=WI.getStrValue((String)vReqInfo.elementAt(11),"&nbsp;")%></strong></td>
    </tr>
    <%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="2"><a href="javascript:Forward();">Click here for other format</a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="19" colspan="3">SUPPLIERS:</td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 1 </td>
			<%				
				strTemp = WI.fillTextValue("supplier1");
			%>
      <td width="83%" height="19"><select name="supplier1" onChange="ReloadPage();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[0],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 2 </td>
			<%				
				strTemp = WI.fillTextValue("supplier2");
			%>
      <td width="83%" height="19"><select name="supplier2" onChange="ReloadPage();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[1],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 3</td>
			<%				
				strTemp = WI.fillTextValue("supplier3");
			%>
      <td width="83%" height="19"><select name="supplier3" onChange="ReloadPage();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[2],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 4</td>
			<%				
				strTemp = WI.fillTextValue("supplier4");
			%>
      <td width="83%" height="19"><select name="supplier4" onChange="ReloadPage();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[3],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>		
    <tr>
      <td width="3%" height="19">&nbsp;</td>
      <td width="14%" height="19">Supplier 5</td>
			<%				
				strTemp = WI.fillTextValue("supplier5");
			%>
      <td width="83%" height="19"><select name="supplier5" onChange="ReloadPage();">
        <option value="">Select supplier</option>
        <%=dbOP.loadCombo("PROFILE_INDEX","SUPPLIER_CODE"," from PUR_SUPPLIER_PROFILE " +
		  " where is_del = 0 and status = 1 and PROFILE_INDEX not in (" + WI.getStrValue(astrSuppliers[4],"0") + 
			") order by SUPPLIER_CODE asc", strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="19">&nbsp;</td>
      <td height="19">&nbsp;</td>
      <td height="19">&nbsp;</td>
    </tr>				
  </table>
	<%}%>
  <%if(vRows != null && vRows.size() > 0){%>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="23" colspan="5" align="center" class="thinborder"><strong><font color="#FFFFFF">ITEMS FOR CANVASSING </font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td class="thinborder">&nbsp;</td>
      <td height="26" class="thinborder">&nbsp;</td>
      <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td colspan="3" align="center" class="thinborder"><%=(String)vColumns.elementAt(iCol)%></td>
      <%}%>
    </tr>
    <tr>
      <td width="25%" align="center" class="thinborder"><font size="1"><strong>ITEM 
        / PARTICULARS / DESCRIPTION </strong></font></td>
      <td width="12%" height="26" align="center" class="thinborder"><font size="1"><strong>QTY</strong></font> / <font size="1"><strong>UNIT</strong></font></td>
      <%for(int iCol = 0; vColumns.size() > iCol; iCol+=2) {%>
      <td align="center" class="thinborder"><font size="1"><strong>REG PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>DISC PRI </strong></font></td>
      <td align="center" class="thinborder"><font size="1"><strong>TOTAL AMT</strong></font></td>
      <%}%>
    </tr>
    <%
	for(iLoop = 0,iCount = 1;iLoop < vRows.size();iLoop+=6,++iCount){
		vRowCols = (Vector) vRows.elementAt(iLoop+5);
	%>
    <tr>
      <td class="thinborder"><%=(String)vRows.elementAt(iLoop)%> / <%=(String)vRows.elementAt(iLoop+1)%></td>
      <td height="25" class="thinborder"><%=(String)vRows.elementAt(iLoop+2)%> <%=(String)vRows.elementAt(iLoop+3)%></td>
      <%for(j = 0;j < vRowCols.size(); j+=3){
		  strTemp = (String)vRowCols.elementAt(j + 2);
		  strTemp = ConversionTable.replaceString(strTemp,",","");
		  dTemp = Double.parseDouble(strTemp);
		  
		  strTemp = (String)vRowCols.elementAt(j);
		  strTemp2 = (String)vRowCols.elementAt(j + 1);
		  strTemp3 = (String)vRowCols.elementAt(j + 2);
		  if(dTemp == 0){
			  strTemp = "&nbsp;";
			  strTemp2 = "&nbsp;";
			  strTemp3 = "&nbsp;";
		  }			
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
      <td align="right" class="thinborder"><%=strTemp2%></td>
      <td align="right" class="thinborder"><%=strTemp3%></td>
      <%}%>
    </tr>
    <%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" align="center"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print search result</font></td>
    </tr>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="printPage" value="">
	<input type="hidden" name="req_no" value="<%=WI.fillTextValue("req_no")%>">
	<input type="hidden" name="canvass_no" value="<%=WI.fillTextValue("canvass_no")%>">
	<input type="hidden" name="is_supply" value="<%=WI.fillTextValue("is_supply")%>">
	<input type="hidden" name="is_canvass" value="1">
	<input type="hidden" name="canvass_date" value="<%=WI.fillTextValue("canvass_date")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
