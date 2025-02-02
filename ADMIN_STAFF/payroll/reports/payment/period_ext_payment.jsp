<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRExternalPayment"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee balances</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TABLE.thinborder{
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">   
function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	document.form_.proceed.value = "1";
	this.SubmitOnce("form_");
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
		}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.print_page.value="";
 	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.proceed.value = "1";	
	document.form_.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function viewPaymentDetail(strPayIndex) {
	var pgLoc = "./payment_details.jsp?payment_index="+strPayIndex;
 	var win=window.open(pgLoc,"payDetail",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strEmpID = null;
	boolean bolHasTeam = false;
	boolean bolHasConfidential = false;
//add security here.
		
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./period_ext_payment_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
		
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
		}
	}

	strEmpID = WI.fillTextValue("emp_id");
	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}	else if(iAccessLevel == 0) //NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Employee Payable Balances","period_ext_payment.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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

	//end of authenticaion code.	
	PRExternalPayment prExt = new PRExternalPayment(request);
	Vector vLoans = null;
	Vector vPersonalDetails = null;
	Vector vPostCharges = null;
	Vector vRetResult = null;
	int iCount = 1;
	int i = 0;
	int iSearchResult = 0;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};	
	String[] astrSortByName    = {"OR Number","Date Paid"};
	String[] astrSortByVal     = {"or_number","date_paid"};
  	
	if (WI.fillTextValue("proceed").length() > 0) { 
		vRetResult = prExt.getPeriodExtPayments(dbOP, request);
		if(vRetResult == null)
			strErrMsg = prExt.getErrMsg();
		else
			iSearchResult = prExt.getSearchCount();
		//System.out.println("vRetResult " + vRetResult);
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="period_ext_payment.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: REPORTS - EMPLOYEE EXTERNAL PAYMENT PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"")%></strong></font> </td>
    </tr>
  </table>
 	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="19%">Date Paid </td>
      <td colspan="3">From
        <input name="date_from" type="text" size="10" maxlength="10"
	  value="<%=WI.fillTextValue("date_from")%>" class="textbox"
	  onKeyUp="AllowOnlyIntegerExtn('form_','date_from','/');"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_from','/')">
          <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to
        &nbsp;&nbsp;
              <input name="date_to" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("date_to")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onKeyUp = "AllowOnlyIntegerExtn('form_','date_to','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_to','/')">
            <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>OR Number</td>
      <td colspan="3"><strong>
        <select name="or_number_con">
          <%=prExt.constructGenericDropList(WI.fillTextValue("or_number_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>				
        <input name="or_number" type="text" value="<%=WI.fillTextValue("or_number")%>"
	    size="10" maxlength="10" style="text-align:right">
      </strong></td>
    </tr> 
     
    <tr>
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr> 
    <tr>
      <td>&nbsp;</td>
      <td height="18" colspan="2"><%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
          <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
        View ALL </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">Sort by</td>
      <td height="18"><select name="sort_by1">
          <option value="">N/A</option>
          <%=prExt.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27"><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27"><!--
			<a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
          <input type="button" name="proceed_btn2" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
          <font size="1">click to list loan balances</font></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  
  <tr>
    <td align="center"><table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="18" colspan="2"><div align="right"><font size="2">	    
		Number of records per page :</font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i =15; i <=35 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}
			}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></div></td>
    </tr>
  <%		
	if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/prExt.defSearchSize;		
	if(iSearchResult % prExt.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td colspan="2"><div align="right"><font size="2">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          </font></div></td>
   </tr>
	 <%}	 
	 }%>
  </table></td>
  </tr>
  <tr>
    <td align="center"><table width="80%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="26" colspan="6" align="center" bgcolor="#B9B292" class="BorderBottomLeft"><strong>LIST
      OF EXTERNAL PAYMENTS </strong></td>
    </tr>
    <tr>
      <td width="33%" align="center" class="BorderBottomLeft"><strong><font size="1">PAYEE</font></strong></td>
      <td width="19%" height="28" align="center" class="BorderBottomLeft"><strong><font size="1">OR NUMBER </font></strong></td>
      <td width="19%" align="center" class="BorderBottomLeft"><font size="1"><strong>AMOUNT PAID </strong></font></td>
      <td align="center" class="BorderBottomLeft"><font size="1"><strong>DATE PAID </strong></font></td>
      <td align="center" class="BorderBottomLeft"><strong><font size="1">DETAIL</font></strong></td>
      <!--
			<td align="center" class="BorderBottomLeft"><font size="1"><strong>POSTED BY</strong></font></td>
			-->
      </tr>
	<% for (i = 0; i < vRetResult.size(); i+=10){%>
    <tr>
			<%
			strTemp = (String)vRetResult.elementAt(i+5);
			%>		
      <td class="BorderBottomLeft"><font size="1">&nbsp;<%=WI.getStrValue(strTemp, "n/a")%></font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+3);
			%>
      <td height="21" class="BorderBottomLeft"><font size="1">&nbsp;<%=strTemp%></font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+1);
			%>
	    <td align="right" class="BorderBottomLeft"><font size="1"><%=CommonUtil.formatFloat(strTemp, true)%>&nbsp;</font></td>
			<%
			strTemp = (String)vRetResult.elementAt(i+2);
			%>			
      <td width="21%" class="BorderBottomLeft"><font size="1">&nbsp;<%=strTemp%></font></td>
      <td width="8%" align="center" class="BorderBottomLeft"><a href="javascript:viewPaymentDetail('<%=(String)vRetResult.elementAt(i)%>')">view</a></td>
      </tr>
    <%} //end for loop%>
  </table></td>
  </tr>
</table>
	
	<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
	<input type="hidden" name="show_all" value="1">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>