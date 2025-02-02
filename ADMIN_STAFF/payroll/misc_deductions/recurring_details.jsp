<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
///added code for HR/companies.

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	String strEmpID = null;	
//add security here.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Detailed Recurring deductions Payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--  

function ReloadPage()
{
 	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
 
function PrintPg(){
 	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
} 
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="recurring_details_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Per Employee)","recurring_details.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"recurring_details.jsp");

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
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEmpList = null;
Vector vDate = null;
double dTemp = 0d;
double dTotal = 0d;

PRMiscDeduction prd = new PRMiscDeduction(request);
	
	String strSchCode = dbOP.getSchoolIndex();

	int iSearchResult = 0;
	int i = 0;
	Vector vEmpInfo = null; 
 	vRetResult = prd.getRecurringDetails(dbOP, request, WI.fillTextValue("post_deduct_index"));
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prd.getErrMsg();
	else{
		iSearchResult = prd.getSearchCount();
		vEmpInfo = (Vector)vRetResult.elementAt(0);
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="recurring_details.jsp" method="post" name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td height="23" colspan="4"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>		
</table>	
	<% if (vEmpInfo !=null && vEmpInfo.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="28">&nbsp;</td>
      <td height="28">Employee Name : <strong><%=WI.formatName((String)vEmpInfo.elementAt(2), (String)vEmpInfo.elementAt(3),
							(String)vEmpInfo.elementAt(4), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vEmpInfo.elementAt(6);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vEmpInfo.elementAt(7));
	}else{
		strTemp += WI.getStrValue((String)vEmpInfo.elementAt(7)," :: ","","");
	}
%>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="96%">Employment Type/Position : <strong><%=(String)vEmpInfo.elementAt(7)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("view_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td><input type="checkbox" name="view_all" value="1" <%=strTemp%> onClick="ReloadPage();">
      show all </td>
    </tr>    
    <tr>
      <td height="17" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
<% 
if (vRetResult != null &&  vRetResult.size() > 1) {
	String strTDColor = null;//grey if already deducted.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <%if(strSchCode.startsWith("ILIGAN")){%>
		<tr>
			<%
				strTemp = WI.fillTextValue("remarks");
				if(strTemp.length() == 0)
					strTemp = "Received the amount as full & complete payment";				
			%>
      <td height="10" colspan="2">Remarks : <input type="text" class="textbox" name="remarks" value="<%=strTemp%>"
				 maxlength="256" size="48"></td>
    </tr>
		<%}%>
    <tr>
      <td height="10" colspan="2" align="right"><font size="2">Number of  rows Per 
        Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
      <font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" ></a> click to print</font>&nbsp;</td>
    </tr>    
    <%
		if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/prd.defSearchSize;		
		if(iSearchResult % prd.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr>
      <td height="10" colspan="2"><div align="right">Jump To page:
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
      </div></td>
    </tr>
		<%}
		}%>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center"><table width="80%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="26" colspan="3" align="center" bgcolor="#B9B292" class="thinborder"><strong><%=WI.fillTextValue("deduction_name").toUpperCase()%> DEDUCTIONS</strong></td>
      </tr>
      <tr>
        <td width="23%" height="28" align="center" class="thinborder">&nbsp;</td>
        <td width="42%" align="center" class="thinborder"><font size="1"><strong>DATE DEDUCTED</strong></font></td>
        <td align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
      </tr>
      <% 
			int iCount = 1;
			for (i = 1; i < vRetResult.size(); i+=8,iCount++){%>
      <tr>
        <td height="25" class="thinborder" align="center"><%=iCount%>&nbsp;</td>
        <td width="42%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true);
				dTotal += Double.parseDouble(ConversionTable.replaceString(strTemp, ",",""));				
				%>
        <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
      </tr>
      <%} //end for loop%>
			<tr>
        <td height="25" colspan="2" align="right" class="thinborder">TOTAL PAYMENTS : </td>        
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
      </tr>      
    </table></td>
  </tr>
</table>

  <% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="post_deduct_index" value="<%=WI.fillTextValue("post_deduct_index")%>">
	<input type="hidden" name="deduction_name" value="<%=WI.fillTextValue("deduction_name")%>">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
