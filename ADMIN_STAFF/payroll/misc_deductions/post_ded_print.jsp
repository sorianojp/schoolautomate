<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Posted Misc Deductions</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>


<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

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

function PrepareToEdit(strInfoIndex){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./post_ded.jsp?emp_id="+document.form_.emp_id.value;
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function viewList(table,indexname,colname,labelname)
{
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=form_";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}


-->
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","post_ded.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"post_ded.jsp");
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
double dTotalAmount = 0d;
double dTotalPayable = 0d;
double dTemp = 0d;

PRMiscDeduction prd = new PRMiscDeduction(request);

if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}	
}

%>
<body onLoad="javascript:window.print();">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%> </font></div></td>
    </tr>
    <tr> 
      <td width="36" height="18">&nbsp;&nbsp;<strong> <%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
    <tr> 
      <td height="10"><hr size="1"></td>
    </tr>
  </table>
 <input name="emp_id" type="hidden" class="textbox" value="<%=WI.fillTextValue("emp_id")%>">
<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="5%" height="23">&nbsp;</td>
      <td width="45%">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td width="50%" height="23">Employee ID :<strong><%=WI.fillTextValue("emp_id")%></strong> 
      </td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="23" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="23">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%> 
        </strong></td>
      <td height="23">Employment Status : <strong><%=(String)vPersonalDetails.elementAt(16)%> 
      </strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="right">Print Date : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
<% vRetResult = prd.operateOnMiscDeductions(dbOP,request,4);
	if (vRetResult != null &&  vRetResult.size() > 0) {%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td height="26" colspan="7" align="center" class="thinborder"><strong>LIST 
    OF POSTED MISCELLANEOUS DEDUCTIONS</strong></td>
  </tr>
  <tr> 
    <td width="26%" align="center" class="thinborder"><strong><font size="1">DEDUCTION 
    NAME</font></strong></td>
    <td width="16%" height="28" align="center" class="thinborder"><strong><font size="1">START DEDUCTION<br>
(in System) </font></strong></td>
    <td width="22%" align="center" class="thinborder"><strong><font size="1">DEDUCTION RANGE </font></strong></td>
    <td width="11%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
    <td align="center" class="thinborder"><font size="1"><strong>PAYABLE 
    BALANCE</strong></font></td>
    <td align="center" class="thinborder"><font size="1"><strong>DATE POSTED</strong></font></td>
    <!--
		<td align="center" class="thinborder"><font size="1"><strong>POSTED BY</strong></font></td>
		-->
  </tr>
  <% for (int i = 0; i < vRetResult.size(); i+=25){
 		strTemp = (String)vRetResult.elementAt(i + 8);
 		if(strTemp != null && !strTemp.equals("0")){
			if(strTemp.equals("2")){
				strTemp2 = "Recurring";
			}else if(strTemp.equals("3")){
				strTemp2 = "Stopped";
			} else {
				strTemp2 = "&nbsp;";
			}
		}else{
			strTemp2 = (String)vRetResult.elementAt(i+5);
 		}	
	%>
  <tr> 
    <td height="23" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;<%=strTemp2%></font></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+18)); 
				strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+19));
				strTemp2 = WI.getStrValue(strTemp, ""," - "+strTemp2, "&nbsp;"); 
			%>
    <td class="thinborder"><font size="1">&nbsp;<%=strTemp2%></font></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+6);
			dTemp = Double.parseDouble(strTemp);
			strTemp = CommonUtil.formatFloat(strTemp, true);
			if(dTemp == 0d)
				strTemp = "&nbsp;";			
			dTotalAmount += dTemp;
		%>
    <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+13);
			dTemp = Double.parseDouble(strTemp);
			strTemp = CommonUtil.formatFloat(strTemp, true);
			if(dTemp == 0d)
				strTemp = "&nbsp;";
			dTotalPayable += dTemp;
		%>		
    <td width="11%" align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
    <td width="14%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
		<!--
    <td width="23%" height="25" class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+10),
								(String)vRetResult.elementAt(i+11),(String)vRetResult.elementAt(i+12),4)%></font></td>
		-->				
  </tr>
  <%} //end for loop%>
  <tr>
    <td height="23" colspan="3" align="right" class="thinborder"><strong>TOTAL : </strong></td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalAmount, true)%>&nbsp;</td>
    <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotalPayable, true)%>&nbsp;</td>
    <td align="center" class="thinborder">&nbsp;</td>
  </tr>
	
</table>
<% } // end vRetResult != null && vRetResult.size() > 0
}// end if Employee ID is null %>
</body>
</html>
<%
dbOP.cleanUP();
%>