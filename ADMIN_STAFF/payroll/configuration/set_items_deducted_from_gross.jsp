<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYROLL: SET ITEMS DEDUCTED FROM GROSS INCOME FOR TAX COMPUTATION</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./set_items_included_comp_adtl_pay.jsp?year="+document.form_.year.value;
}

function ShowAll() {
	var pgLoc = "./set_items_deducted_from_gross_all.jsp";
	var win=window.open(pgLoc,"ShowAll",'dependent=yes,width=700,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}


function focusID() {
	document.form_.emp_id.focus();
}

-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="set_items_deducted_from_gross_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_items_deducted_from_gross.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"set_items_deducted_from_gross.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION-ITEMDED",request.getRemoteAddr(), null);
}

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

//end of authenticaion code.
Vector vRetResult = null;

PayrollConfig pr = new PayrollConfig();

String strPageAction = WI.fillTextValue("page_action");
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnGrossIncDeduct(dbOP,request,0) != null){
			strErrMsg = "  Deduction removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnGrossIncDeduct(dbOP,request,1) != null){
			strErrMsg = " Deduction posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}

vRetResult = pr.operateOnGrossIncDeduct(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}

String[] astrDeductGrossInc = {"SSS","PAG-IBIG","Philhealth","COLA/ECOLA", "GSIS","Overtime pay",
															 "Night Differential","Holiday Pay", "Additional responsibilities",
															 "Additional Bonus", "Additional Pay", "Substitute teaching", "Overload"};
%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./set_items_deducted_from_gross.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: ITEMS DEDUCTED FROM GROSS INCOME FOR TAX COMPUTATION PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"> &nbsp;&nbsp; &nbsp;<%=WI.getStrValue(strErrMsg,"<font size='3' color='#FF0000'><strong>","</strong></font>","")%></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="29%">Payroll Year Effectivity : 
        <input name="year" type="text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','year')" value="<%=WI.fillTextValue("year")%>" size="4" maxlength="4"></td>
      <td width="14%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td width="55%"><a href="javascript:ShowAll();"><img src="../../../images/show_list.gif" border="0"></a><font size="1">click 
        to show all list of items for all payroll year</font></td>
    </tr>
  </table>
<% if (WI.fillTextValue("year").length() == 4) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
			<% int iLen = astrDeductGrossInc.length;
				if(!bolIsSchool)
					iLen = iLen - 2;
			%>
      <td colspan="3">Items : &nbsp;&nbsp;&nbsp; 
			<select name="deduct_gross">	      	
				 <%for (int i = 0; i <  iLen; i++){%>					
				  <%if (Integer.parseInt(WI.getStrValue(WI.fillTextValue("deduct_gross"),"0")) == i){ %>
          <option value="<%=i%>" selected><%=astrDeductGrossInc[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrDeductGrossInc[i]%></option>
          <%}}%>
        </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="bottom">&nbsp;</td>
      <td height="18" valign="bottom">&nbsp;</td>
      <td height="18" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="76%" height="25">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:AddRecord()"><img src="../../../images/add.gif" width="42" height="32" border="0"></a><font size="1">click 
        to save entries</font>
				<%}%>
				</td>
      <td width="19%" height="25"><font size="1">&nbsp;</font></td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="57%">&nbsp;</td>
      <td width="42%" height="25" align="right">
<%if (vRetResult != null) {%>	  
	  <font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click 
          to print list</font>
<%}%> </td>
    </tr>
  </table>
  <% if (vRetResult != null) {  %>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" align="center" bgcolor="#B9B292">LIST OF 
      ITEMS DEDUCTED FROM GROSS INCOME FOR TAX COMPUTATION</td>
    </tr>
    <tr> 
      <td width="572" height="26" align="center"><strong><font size="1">ITEMS</font></strong></td>
      <td width="64" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
<% for (int i  = 0; i < vRetResult.size(); i+=3) {  
	if ((String)vRetResult.elementAt(i+1) != null) { %>
	<tr> 
      <td height="25" colspan="2">&nbsp;YEAR : <strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
    </tr>
	<%} // end if %>
    <tr> 
      <td height="25"> &nbsp;&gt;&gt; &nbsp;<%=astrDeductGrossInc[Integer.parseInt((String)vRetResult.elementAt(i+2))]%>
      <td align="center">
			<%if(iAccessLevel == 2){%>
			<a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
			<%}else{%>
				N/a
			<%}%>
			</td>
    </tr>
    <% } //end for int i = 0 loop%>
  </table>
<%} //  vRetResult != null 
} // end year length != 4%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>