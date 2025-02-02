<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Daily cash collection page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg() {
	document.bgColor = "#FFFFFF";
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
	
	var oRows = document.getElementById('myADTable2').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i) 
		document.getElementById('myADTable2').deleteRow(0);

   	//document.getElementById('myADTable2').deleteRow(0);
   	//document.getElementById('myADTable2').deleteRow(0);
   	//document.getElementById('myADTable2').deleteRow(0);
   	//document.getElementById('myADTable2').deleteRow(0);
   	//document.getElementById('myADTable2').deleteRow(0);
   	//document.getElementById('myADTable2').deleteRow(0);
   	//document.getElementById('myADTable2').deleteRow(0);

   	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function ReloadPage() {
	document.form_.show_list.value='';
	document.form_.submit();
}
function DeleteProj() {
	document.form_.delete_proj.value='1';
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","major_exam_summary.jsp");
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
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"major_exam_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

//get different grant here.
FeeExtraction feeEx = new FeeExtraction();

Vector vRetResult = null;

if(WI.fillTextValue("delete_proj").length() > 0) {
	dbOP.executeUpdateWithTrans("update FA_FEE_HISTORY_PROJECTED_COL_RUNDATE set IS_RUNNING = 0, TO_PROCESS = 0", null, null, false);	 
	strErrMsg = "Lock removed. Click Refresh to generate the report.";
}
else if(WI.fillTextValue("pmt_schedule").length() > 0) {
	vRetResult = feeEx.getProjectedCollectionNew(dbOP, request);
	strErrMsg = feeEx.getErrMsg();	
}

if(WI.fillTextValue("show_list").length() > 0) {
	//System.out.println("Printoing.. ");	
	//System.out.println("Printoing.. "+feeEx.getCollectionReport(dbOP, request));
	//System.out.println(feeEx.getErrMsg());
	vRetResult = feeEx.getCollectionReport(dbOP, request);
	if(vRetResult == null)
		strErrMsg = feeEx.getErrMsg();
}


boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) 
	bolIsBasic = true;

Vector vPNDP       = new Vector();
Vector vPNPrelim   = new Vector();
Vector vPNMidterm  = new Vector();
Vector vPNFinal    = new Vector();

Vector vDiscount   = new Vector();
Vector vStudPlan   = new Vector();

if(vRetResult != null && vRetResult.size() > 0) {
	String strPrelimExam  = null;
	String strMidtermExam = null;
	String strFinalExam   = null;
	
	java.sql.ResultSet rs = null;
	String strSQLQuery = "select pmt_sch_index,exam_name from fa_pmt_schedule where is_valid = 1 order by exam_period_order";
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
		strPrelimExam  = rs.getString(1);
		rs.next();
		strMidtermExam = rs.getString(1);
		rs.next();
		strFinalExam   = rs.getString(1);
	}
	rs.close();
	int iPmtSch = 0;
	strSQLQuery = "select pmt_sch_index, user_index from fa_stud_promisory_note where is_temp_stud_ = 0 and is_valid = 1 and sy_from = "+WI.fillTextValue("sy_from")+
				" and semester = "+WI.fillTextValue("semester");
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		iPmtSch = rs.getInt(1);
		if(iPmtSch == 0) {
			vPNDP.addElement(new Integer(rs.getInt(2)));
			continue;
		}
		if(strPrelimExam.equals(Integer.toString(iPmtSch)))
			vPNPrelim.addElement(new Integer(rs.getInt(2)));
		else if(strMidtermExam.equals(Integer.toString(iPmtSch)))
			vPNMidterm.addElement(new Integer(rs.getInt(2)));
		else if(strFinalExam.equals(Integer.toString(iPmtSch)))
			vPNFinal.addElement(new Integer(rs.getInt(2)));
	}
	rs.close();

	strSQLQuery =
        "select MAIN_TYPE_NAME,SUB_TYPE_NAME1,SUB_TYPE_NAME2,SUB_TYPE_NAME3," +//4
        "SUB_TYPE_NAME4,SUB_TYPE_NAME5,DISCOUNT,DISCOUNT_UNIT,DISCOUNT_ON,"+//9
        "DIS_MISC,DIS_MISC_UNIT,DIS_OTH,DIS_OTH_UNIT,user_index "+//14 -- additional disc.
        "from FA_STUD_PMT_ADJUSTMENT "+
        "join FA_FEE_ADJUSTMENT on (FA_STUD_PMT_ADJUSTMENT.fa_fa_index=FA_FEE_ADJUSTMENT.fa_fa_index) "+
        "where FA_STUD_PMT_ADJUSTMENT.is_valid=1 and " +"FA_STUD_PMT_ADJUSTMENT.sy_from=" + WI.fillTextValue("sy_from") +
		" and FA_STUD_PMT_ADJUSTMENT.semester=" + WI.fillTextValue("semester");
	String[] astrConvertToDiscUnit = {" Amt","%"," Load Unit"};
	String[] astrConvertToDiscOn   = {" Tuition"," Misc"," Free all"," Oth Charge",
	  " Tuition+Misc"," Misc+Oth"," Oth Charges","Tuition+Misc+Oth"};
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
        strTemp = rs.getString(1);
        if (rs.getString(2) != null) {
          strTemp = rs.getString(2);
          if (rs.getString(3) != null) {
            strTemp = rs.getString(3);
            if (rs.getString(4) != null) {
              strTemp = rs.getString(4);
              if (rs.getString(5) != null) {
                strTemp = rs.getString(5);
                if (rs.getString(6) != null)
					strTemp = rs.getString(6);
              }
            }
          }
        }
		strTemp = strTemp+" "+rs.getString(7)+ astrConvertToDiscUnit[rs.getInt(8)]+astrConvertToDiscOn[rs.getInt(9)];	
		vDiscount.addElement(new Integer(rs.getInt(14)));
		vDiscount.addElement(strTemp);
	}
	rs.close();


	//get plan of student.
	strSQLQuery = "select stud_index, plan_name from FA_STUD_MIN_REQ_DP_PER_STUD "+
			"join FA_STUD_PLAN_FATIMA on (FA_STUD_PLAN_FATIMA.plan_ref = FA_STUD_MIN_REQ_DP_PER_STUD.plan_ref) "+
			" where IS_TEMP_STUD = 0 and SY_FROM = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vStudPlan.addElement(new Integer(rs.getInt(1)));//[0] stud_index
		vStudPlan.addElement(rs.getString(2));//[1] plan_name
	}
	rs.close();
}

%>

<form name="form_" method="post" action="./collection_report_fatima_assessment_profile.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ASSESSMENT PROFILE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%">&nbsp;</td>
	  <td><strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="12%" height="25">SY/Term</td>
      <td height="25" colspan="2"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
          <option value="">ALL</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>        
<%
if(!strSchCode.startsWith("FATIMA")) {%>
	<font style="font-weight:bold; color:#0000FF; font-size:11px;">
		<input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="ReloadPage();"> Generate For Basic	</font>
<%}%>		</td>
    </tr>
<%if(bolIsBasic) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Grade Level</td>
      <td colspan="2">
	  <select name="year_level">
          <option value="">ALL</option>
	  	<%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%>
        </select>	  </td>
    </tr>
<%if(strSchCode.startsWith("EAC")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Campus</td>
      <td colspan="2">
		<select name="basic_sch_index">
		<option value=""></option>
        <%=dbOP.loadCombo("SCH_INDEX","SCH_NAME"," from SCHOOL_LIST order by SCH_NAME",WI.fillTextValue("basic_sch_index"),false)%> 
		</select>	  </td>
    </tr>
<%}

}else{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="2">
	  <select name="course_index">
          <option value="">ALL</option>
<%
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
%>
          <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
        </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Year Level </td>
      <td colspan="2">
	  <select name="year_level">
	  <option value="">ALL</option>
<%
strTemp = WI.fillTextValue("year_level");
int iDefVal = Integer.parseInt(WI.getStrValue(strTemp, "0"));
		for(int i = 1; i < 7; ++i) {
			if(iDefVal == i)
				strTemp = " selected";
			else	
				strTemp ="";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>	  </td>
    </tr>
<%}%>    <tr>
      <td height="25">&nbsp;</td>
      <td>Student ID </td>
      <td colspan="2">	  
	  	<input name="stud_id" type="text" size="24" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  	
<%if(strSchCode.startsWith("FATIMA")){%>
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <font size="1" style="font-weight:bold; color:#0000FF"><input type="checkbox" name="only_tuition" value="checked" <%=WI.fillTextValue("only_tuition")%>>
	  Show Only Tuition </font>	  
<%}%>

			  </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">
		<input type="submit" name="1" value="&nbsp;&nbsp;Show Result&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_list.value='1'">	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25" class="thinborderBOTTOM">&nbsp;</td>
      <td height="25" colspan="2" class="thinborderBOTTOM">&nbsp;</td>
      <td width="31%" class="thinborderBOTTOM">&nbsp; <%if(vRetResult != null) {%> <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> 
        <font size="1">click to print</font> <%}%> </td>
    </tr>
  </table>

<!------------------- display report here ------------------------->
<%if(vRetResult != null) {
boolean bolIncOldAccount = false;
//if(WI.fillTextValue("inc_old_account").length() > 0) 
	bolIncOldAccount = true;

int iIndexOf = 0;
String strReportTitle = "";
    if(WI.fillTextValue("date_from").length() > 0) {
      if(WI.fillTextValue("date_to").length() > 0)
        strReportTitle = " From "+WI.fillTextValue("date_from")+" to "+ WI.fillTextValue("date_to");
      else 
        strReportTitle += " For "+WI.fillTextValue("date_from");
    }
	if(WI.fillTextValue("as_of").length() > 0) 
		strReportTitle += " As Of "+WI.fillTextValue("as_of");
	if(WI.fillTextValue("basic_sch_index").length() > 0) {
		String strSchoolName = "select sch_name from SCHOOL_LIST where sch_index = "+WI.fillTextValue("basic_sch_index");
		strSchoolName = dbOP.getResultOfAQuery(strSchoolName, 0);
		if(strSchoolName != null)
			strReportTitle = " <br> For Campus "+strSchoolName;
	}
	
	
String[] astrConvertTerm = {"Summer","1st Semester","2nd Semester","3rd Semester"};%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="2"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td colspan="2"><div align="center"></div></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="top"><div align="center"><strong>ASSESSMENT PROFILE REPORT <%=strReportTitle.toUpperCase()%><br>
		  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
          </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="42%" height="24">&nbsp;</td>
      <td height="24" align="right">Date and time printed : &nbsp;<%=WI.getTodaysDateTime()%> &nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    
    <tr align="center" style="font-weight:bold">
      <td width="2%" style="font-size:9px;" align="left" class="thinborder">Count</td> 
      <td width="15%" height="24" style="font-size:9px;" align="left" class="thinborder">Student ID </td>
      <td width="18%" style="font-size:9px;" align="left" class="thinborder">Student Name </td>
      <td width="10%" style="font-size:9px;" align="left" class="thinborder">Course</td>
<%if(!bolIsBasic){%>
      <td width="10%" style="font-size:9px;" align="left" class="thinborder">Year</td>
<%}%>
      <td width="12%" style="font-size:9px;" align="left" class="thinborder">Date Enrolled </td>
      <td width="6%" style="font-size:9px;" class="thinborder" align="center">Plan</td>
      <%if(bolIncOldAccount ) {%>
	  	<td width="8%" style="font-size:9px;" class="thinborder">Old Account</td>
	  <%}%>
      <td width="8%" style="font-size:9px;" class="thinborder">Tot Assessment</td>
      <td width="12%" style="font-size:9px;" class="thinborder">Discount Type </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Total Discount </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Total Adjustment </td>
      <td width="8%" style="font-size:9px;" class="thinborder">Payment</td>
      <td width="8%" style="font-size:9px;" class="thinborder">Balance</td>
      <td width="4%" style="font-size:9px;" class="thinborder">PN <br>D/P </td>
      <td width="4%" style="font-size:9px;" class="thinborder">PN <br>Perlim </td>
      <td width="4%" style="font-size:9px;" class="thinborder">PN <br>Midterm</td>
      <td width="4%" style="font-size:9px;" class="thinborder">PN <br>Final </td>
    </tr>
	<%
	double dTemp = 0d;
	
	double dBalance    = 0d;
	double dOldAccount = 0d;
	double dCurCharge  = 0d;
	double dDiscount   = 0d;
	double dAdjustment = 0d;
	double dPayment    = 0d;
	//System.out.println(vRetResult);

	double dTotalBalance    = 0d;
	double dTotalOldAccount = 0d;
	double dTotalCurCharge  = 0d;
	double dTotalDiscount   = 0d;
	double dTotalAdjustment = 0d;
	double dTotalPayment    = 0d;
	
	String strStudPlan      = null;
	
	Vector vInfo = null;
	int iCount = 0; 
	for(int i = 0; i < vRetResult.size(); i += 7){
	//System.out.println(vPNDP);
	//System.out.println(vRetResult);
	//System.out.println(vPNDP.indexOf(vRetResult.elementAt(i)));
	
		iIndexOf = vDiscount.indexOf(vRetResult.elementAt(i));
		if(iIndexOf == -1)
			strTemp = "&nbsp;";
		else	
			strTemp = (String)vDiscount.elementAt(iIndexOf + 1);
		
		iIndexOf = vStudPlan.indexOf(vRetResult.elementAt(i));
		if(iIndexOf == -1)
			strStudPlan = "&nbsp;";
		else	
			strStudPlan = (String)vStudPlan.elementAt(iIndexOf + 1);

		vInfo = (Vector)vRetResult.elementAt(i + 6);
		if(vInfo == null)
			vInfo = new Vector();
		
		dOldAccount = 0d;
		dCurCharge  = 0d;
		dDiscount   = 0d;
		dAdjustment = 0d;
		dPayment    = 0d;

		if(vInfo.size() > 4) {
			if(bolIncOldAccount)
				dOldAccount = ((Double)vInfo.elementAt(1)).doubleValue();
			dCurCharge  = ((Double)vInfo.elementAt(0)).doubleValue();
			dDiscount   = ((Double)vInfo.elementAt(2)).doubleValue();
			dAdjustment = ((Double)vInfo.elementAt(3)).doubleValue();
			dPayment    = ((Double)vInfo.elementAt(4)).doubleValue();
			
			dBalance = dOldAccount + dCurCharge - dDiscount +  dAdjustment - dPayment;
		}
		dTotalBalance    += dBalance;
		dTotalOldAccount += dOldAccount;
		dTotalCurCharge  += dCurCharge;
		dTotalDiscount   += dDiscount;
		dTotalAdjustment += dAdjustment;
		dTotalPayment    += dPayment;
		
	%>
    <tr align="right">
      <td align="left" class="thinborder"><%=++iCount%>.</td> 
      <td height="24" align="left" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td align="left" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td align="left" class="thinborder">
	  <%if(bolIsBasic) {%>
	  	<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vRetResult.elementAt(i + 4)))%>
	  <%}else{%>
	  	<%=vRetResult.elementAt(i + 3)%>
	  <%}%>	  </td>
<%if(!bolIsBasic){%>
      <td align="left" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
<%}%>
      <td align="left" class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td align="left" class="thinborder"><%=strStudPlan%></td>
      <%if(bolIncOldAccount) {%>
	      <td class="thinborder"><%=CommonUtil.formatFloat(dOldAccount, true)%></td>
      <%}%>
	  <td class="thinborder"><%=CommonUtil.formatFloat(dCurCharge, true)%></td>
      <td class="thinborder" align="left"><%=strTemp%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dDiscount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dAdjustment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dPayment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dBalance, true)%></td>
      <td class="thinborder" align="center"><%if(vPNDP.indexOf(vRetResult.elementAt(i)) > -1) {%>Y<%}else{%>N<%}%></td>
      <td class="thinborder" align="center"><%if(vPNPrelim.indexOf(vRetResult.elementAt(i)) > -1) {%>Y<%}else{%>N<%}%></td>
      <td class="thinborder" align="center"><%if(vPNMidterm.indexOf(vRetResult.elementAt(i)) > -1) {%>Y<%}else{%>N<%}%></td>
      <td class="thinborder" align="center"><%if(vPNFinal.indexOf(vRetResult.elementAt(i)) > -1) {%>Y<%}else{%>N<%}%></td>
    </tr>
	<%}%>
    <tr align="right" style="font-weight:bold">
      <td align="left" class="thinborder">&nbsp;</td>
      <td height="24" align="left" class="thinborder">TOTAL : </td>
      <td align="left" class="thinborder">&nbsp;</td>
      <td align="left" class="thinborder">&nbsp;</td>
<%if(!bolIsBasic){%>
      <td align="left" class="thinborder">&nbsp;</td>
<%}%>
      <td align="left" class="thinborder">&nbsp;</td>
      <td align="left" class="thinborder">&nbsp;</td>
      <%if(bolIncOldAccount) {%>
	      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalOldAccount, true)%></td>
      <%}%>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalCurCharge, true)%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalDiscount, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalAdjustment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalPayment, true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotalBalance, true)%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="69%" height="24"><font size="1">Printed by : <%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),1)%></font></td>
      <td width="12%">&nbsp;</td>
      <td width="19%">&nbsp;</td>
    </tr>
  </table>
<%}//////////////////// end of report ////////////////////%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="show_list">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
