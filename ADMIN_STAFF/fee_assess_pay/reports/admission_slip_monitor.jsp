<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
WebInterface WI = new WebInterface(request);
boolean bolIsEAC = strSchCode.startsWith("EAC");
boolean bolIsUL = strSchCode.startsWith("UL");
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

Vector vTemp = null;
Vector vBalance = new Vector();
//get here the list of student to be printed if the print by course is selected.
Vector vRetResult = null;
enrollment.ReportFeeAssessment RFA = new enrollment.ReportFeeAssessment();
if(WI.fillTextValue("show_list").length() > 0) {
	vRetResult = RFA.getStudListAdmissionSlipPrintStat(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = RFA.getErrMsg();
	else{
		if(bolIsUL){
			double dAmtDue = 0d;
			double dPayableForExamSch = 0d;
			double dTotalPayable = 0d;
			double dPmtAfterExamSch = 0d;
			double dAmtFinalBalanceDue = 0d;
	
		
			enrollment.FAAssessment FAA = new enrollment.FAAssessment();	
			enrollment.FAFeeOperation fOp = new enrollment.FAFeeOperation();	
			String strUserIndex = null;
			strTemp = "select user_index from user_table where id_number= ?";		
			java.sql.PreparedStatement pstmtUserIndex = dbOP.getPreparedStatement(strTemp);
			
			strTemp = " select year_level from stud_curriculum_hist where is_valid =1 and user_index = ? and sy_from = "+WI.fillTextValue("sy_from")+
						" and semester = "+WI.fillTextValue("semester");
			java.sql.PreparedStatement pstmtYearLevel = dbOP.getPreparedStatement(strTemp);
			
			java.sql.ResultSet rs =null;
			String strYearLevel = null;
			for(int i =0 ; i < vRetResult.size(); i += 6){
				strYearLevel = null;
				strUserIndex = null;
				
				pstmtUserIndex.setString(1, (String)vRetResult.elementAt(i));
				rs = pstmtUserIndex.executeQuery();
				if(rs.next())
					strUserIndex = rs.getString(1);
				rs.close();
				if(strUserIndex == null)
					continue;
					
				pstmtYearLevel.setString(1, strUserIndex);
				rs = pstmtYearLevel.executeQuery();
				if(rs.next())
					strYearLevel = rs.getString(1);
				rs.close();
				
				
				
				vTemp = FAA.getInstallmentSchedulePerStudPerExamSch(dbOP, WI.fillTextValue("pmt_schedule"), 
					strUserIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("sy_to"), strYearLevel, WI.fillTextValue("semester"));
				if(vTemp == null || vTemp.size() == 0)
					continue;
					
				 dAmtDue = Double.parseDouble((String)vTemp.elementAt(5));
				 dPayableForExamSch = Double.parseDouble((String)vTemp.elementAt(0));
				 dTotalPayable = Double.parseDouble((String)vTemp.elementAt(6));
				 dPmtAfterExamSch = new enrollment.GradeSystemExtn().getAmtPaidAfterPmtSchedule(dbOP, strUserIndex, WI.fillTextValue("sy_from"), 
				 	WI.fillTextValue("semester"), WI.fillTextValue("pmt_schedule"));
				 dAmtDue -= dPmtAfterExamSch;	
				 
				 dAmtFinalBalanceDue = fOp.calOutStandingOfPrevYearSem(dbOP, strUserIndex, true, true);
				 if (dAmtDue > dAmtFinalBalanceDue) 
					dAmtDue = dAmtFinalBalanceDue;
				  
				 vBalance.addElement((String)vRetResult.elementAt(i)); 	
				 vBalance.addElement(Double.toString(dAmtDue));
			}
		}
	
		
		
		
			

              
             

              

              	
	
	
	}	
		
		
		
		

}	



%>

<form name="form_" action="./admission_slip_monitor.jsp" method="post" onSubmit="SubmitOnceButton(this);">
<input type="hidden" name="group_by_level" value="1">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRINTING OF ADMISSION SLIP TRACKING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
<%if(strSchCode.startsWith("UI") || strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("CSA")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
<%
if(bolIsBasic) 
	strTemp = " checked";
else	
	strTemp = "";
if(strSchCode.startsWith("CSA"))
	strTemp = " checked";
%>
        <input type="checkbox" name="is_basic" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font color="#0000FF"><strong>Check for Grade school</strong></font></td>
    </tr>
<%}%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">SY/TERM</td>
      <td height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

		// force to 1 (regular for basic ) if not summer and if basic
		if (WI.fillTextValue("is_basic").equals("1") && !strTemp.equals("0"))  
			strTemp = "1";
	
		  if(strTemp.equals("1")){
		  %>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("3")){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> &nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td>Exam Period </td>
      <td width="87%"><select name="pmt_schedule">
        <%if(bolIsBasic){%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=2 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}else{%>
        <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("pmt_schedule"), false)%>
        <%}%>
      </select></td>
    </tr>
<%
	if(!bolIsBasic){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"> Course </td>
      <td height="25"><select name="course_index">
          <option value="">Select Any</option>
          <%
//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 and is_offered = 1 and is_visible = 1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="11%" height="25"> Year level </td>
      <td height="25"><select name="year_level" onChange="ReloadPage()">
          <option value="">ALL</option>
          <%
strTemp = request.getParameter("year_level");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("1") ==0)
{%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
    </tr>
<%}//show if basic
   else {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Education Level</td>
      <td>
  <%if(strSchCode.startsWith("WNU")){%>
	  <select name="edu_level">
          <%=dbOP.loadCombo("distinct edu_level","EDU_LEVEL_NAME"," from BED_LEVEL_INFO order by edu_LEVEL",WI.fillTextValue("edu_level"),false)%> 
	  </select>
	  <%}else{%>
	  <select name="year_level">
          <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%> 
      </select>	
	  - 
	  <%if(WI.fillTextValue("sy_from").length() > 0) {%>
	  		  <select name="section_name" onChange="ReloadPage()">
				  <option value=""></option>
					  <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where offering_sy_from = "+WI.fillTextValue("sy_from")+
						" and offering_sem = "+WI.fillTextValue("semester")+" and exists (select * from subject where sub_index = e_sub_section.sub_index and is_del = 2) "+
						" and exists (select * from enrl_final_cur_list where sub_sec_index = e_sub_section.sub_sec_index and is_valid = 1 and current_year_level = "+
						WI.getStrValue(WI.fillTextValue("year_level"), "1")+")",WI.fillTextValue("section_name"),false)%> 
			  </select>
	  <%}%>

  <%}%>		</td>
    </tr>
<%}//show only if basic.%>   
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:9px; font-weight:bold; color:#0000FF">
	  	<input type="checkbox" name="show_not_printed" value="checked" <%=WI.fillTextValue("show_not_printed")%>>Show Not Printed
	  </td>
      <td><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000" id="myADTable3">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5" align="right"><a href="javascript:PrintPG();"> 
        <img src="../../../images/print.gif" border="0"></a> <font size="1">Click 
        to print</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%int iCount = 0;%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#999999"> 
		  <td height="25" align="center" class="thinborderLEFT"><B>List of Students 
		  		<%if(WI.fillTextValue("show_not_printed").length() == 0) {%>Already Printed <%}else {%>Not Printed <%}%>
			Exam Permit For: <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>, <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%></B></td>
		</tr>
	  </table>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
		<tr bgcolor="#ffff99" align="center" style="font-weight:bold"> 
		  <td height="25" width="5%" class="thinborder">COUNT</td>
		  <td width="20%" class="thinborder">STUDENT ID</td>
		  <td width="35%" class="thinborder">STUDENT NAME</td>
<%if(bolIsEAC){%>
		  <td width="15%" class="thinborder">PERMIT NUMBER </td>
<%}%>
		  <td width="15%" class="thinborder">COURSE-YR</td>
	      <%if(bolIsUL){%><td width="15%" class="thinborder">BALANCE</td><%}%>
		</tr>
		<%
		int iIndexOf = 0;
		String strBalance = null;
		for(int i = 0; i < vRetResult.size(); i += 6){
			strBalance = null;
			iIndexOf = vBalance.indexOf((String)vRetResult.elementAt(i));
			if(iIndexOf > -1)
				strBalance = (String)vBalance.elementAt(iIndexOf + 1);
			
		%>
			<tr> 
			  <td class="thinborder" height="25"><%=++iCount%>.</td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
<%if(bolIsEAC){%>
			  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5),"&nbsp;")%></td>
<%}%>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), " - ", "", "")%></td>
			  <%if(bolIsUL){
			  	if(strBalance != null)
					strBalance = CommonUtil.formatFloat(strBalance, true);
				%><td class="thinborder"><%=WI.getStrValue(strBalance,"&nbsp;")%></td><%}%>
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
  <input type="hidden" name="print_pg" value="">  
  <input type="hidden" name="print_all" value="">
  <input type="hidden" name="exam_name" value="">
  <input type="hidden" name="section_selected" value="">
  <input type="hidden" name="show_list">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>