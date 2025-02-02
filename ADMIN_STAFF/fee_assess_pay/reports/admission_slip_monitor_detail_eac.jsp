<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);

boolean bolIsBasic = false;
if (WI.fillTextValue("is_basic").equals("1")) 
	bolIsBasic = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "";
	if(document.form_.sy_to.value.length < 4 || document.form_.sy_from.value.length < 4) {
		alert("Please enter School Year information.");
		return;
	}
	//this.setExamName();
	document.form_.show_list.value='1';
	document.form_.submit();
}
function PrintPG() {
	document.bgColor = "#FFFFFF";
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable3').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);

	obj = document.getElementById('myADTable2');
	if(obj) {
		oRows = obj.getElementsByTagName('tr');
		iRowCount = oRows.length;
		for(i = 0; i < iRowCount; ++i)
			obj.deleteRow(0);
	}
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}



function CallPrint()
{
	this.setExamName();
	
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "1";
}
function NextPage() {
	location = "./admission_slip.jsp?sy_from="+document.form_.sy_from.value+
	"&sy_to="+document.form_.sy_to.value+
	"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
	"&pmt_schedule="+
	document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
}
function PrintALL() {
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "1";
	this.setExamName();
	document.form_.submit();
}
function setExamName() {
	if(!document.form_.pmt_schedule)
		return;
	if(document.form_.section_name && document.form_.section_name.selectedIndex > 0)
		document.form_.section_selected.value = document.form_.section_name[document.form_.section_name.selectedIndex].text;
	
	document.form_.exam_name.value = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
}
//prints the student having balance.. 
function PrintStudentWithBalance() {
	document.bgColor = "#FFFFFF";
	
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	document.getElementById('myADTable5').deleteRow(1);
	
	//delete the dynamic rows.. 
	var obj = document.getElementById('myADTable2');
	var oRows; var iRowCount;
	if(obj) {
		oRows = obj.getElementsByTagName('tr');
		iRowCount = oRows.length;
		for(i = 0; i < iRowCount; ++i)
			obj.deleteRow(0);
	}
	obj = document.getElementById('myADTable3');
	if(obj) {
		oRows = obj.getElementsByTagName('tr');
		iRowCount = oRows.length;
		for(i = 0; i < iRowCount; ++i)
			obj.deleteRow(0);
	}
	
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.

}

//ajax to update admission slip number
function UpdateAdmSlipNo(strIDNumber) {
	var strNewVal = prompt('Please enter Premit Number','');
	if(strNewVal == null || strNewVal == '') 
		return;	
	//I have to update now. 
	var strParam = "user="+escape(strIDNumber)+"&sy_f="+document.form_.sy_from.value+
					"&sem="+document.form_.semester[document.form_.semester.selectedIndex].value+
					"&new_val="+escape(strNewVal)+"&pmt_sch="+document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].value;
	var objCOAInput = document.getElementById(strIDNumber);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	//alert(strParam);
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=122&"+strParam;
	this.processRequest(strURL);
	
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
		//may be called from registrar.
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));		
			if(iAccessLevel == 0) 
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));		
		}
		//may be called from Guidance.
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));		
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS - admission Slip batch print","admission_slip_monitor.jsp");
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

if(strErrMsg == null) 
	strErrMsg = "";

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};


//get here the list of student to be printed if the print by course is selected.
Vector vRetResult = null;
enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();
	vRetResult = RFA.getStudListAdmissionSlipPrintStatDetail(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = RFA.getErrMsg();
//System.out.println(strErrMsg);
boolean bolIsEAC = strSchCode.startsWith("EAC");

%>

<%if(vRetResult != null && vRetResult.size() > 0){%>
<%int iCount = 0;%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#999999"> 
		  <td height="25" align="center" class="thinborderLEFT"><B>List of Students With 
		  		Exam Permit  For: <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%></B></td>
		</tr>
	  </table>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#ffff99" align="center" style="font-weight:bold"> 
		  <td height="25" width="5%" class="thinborder">COUNT</td>
		  <td width="10%" class="thinborder">PERMIT NUMBER </td>
		  <td width="15%" class="thinborder">STUDENT ID</td>
		  <td width="25%" class="thinborder">STUDENT NAME</td>
		  <td width="15%" class="thinborder">SUBJECT CODE </td>
		  <td width="25%" class="thinborder">SUBJECT NAME </td>
	      <td width="5%" class="thinborder">CONTROL NUMBER </td>
		</tr>
		<%for(int i = 0; i < vRetResult.size(); i += 6){%>
			<tr> 
			  <td class="thinborder" height="25"><%=++iCount%>.</td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
			  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
			</tr>
	  	<%}%>
	  </table>
<%}//end of vRetResult display.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>