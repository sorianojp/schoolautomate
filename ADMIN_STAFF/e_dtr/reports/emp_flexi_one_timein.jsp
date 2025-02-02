<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn, 
																 eDTR.AllowedLateTimeIN" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Flexi Employees with single time in</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
 
<!--
body {
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

    TABLE.thinborderall {
    border: solid 1px #000000;
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.dtr_op.print_pg.value="1";
	document.dtr_op.submit();
}

function ReloadPage()
{
	document.dtr_op.print_pg.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	document.dtr_op.submit();
}
 
function ViewRecords()
{
	document.dtr_op.print_pg.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
function checkAllSave() {
	var maxDisp = document.dtr_op.recordcount.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=true');
	}
}

function SaveData()
{
	document.dtr_op.print_pg.value="";
	document.dtr_op.save_record.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_pg") != null && request.getParameter("print_pg").equals("1"))
{ %>
	<jsp:forward page="./emp_login_before_time_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Flexi Employees with one login",
								"emp_flexi_one_timein.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_flexi_one_timein.jsp");	
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

	ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
	AllowedLateTimeIN allowedLateTIN = new AllowedLateTimeIN();
	int i = 0;
	long lTime = 0l;
	int iIndexOf = 0;
	int iPageCount =  1;
	int iJumpTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("jumpto"),"1"));
	int iRowCount = rptExtn.defSearchSize;
	Vector vLateSetting = null;
	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	if(bolIsSchool)
		 strTemp = "College";
	else
		 strTemp = "Division";
	String[] astrSortByName    = {"ID number", strTemp, "Department", "Time in", "Lastname"};
	String[] astrSortByVal     = {"id_number", "c_code", "d_code", "t_in", "lname"};

	String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June", 
											"July", "August", "September","October", "November", "December"};

	String strMonths = WI.fillTextValue("month_of");
	if(strMonths.length() == 0 && WI.fillTextValue("date_fr").length() == 0){
		strTemp = WI.getTodaysDate(1);
		iIndexOf = strTemp.indexOf("/");
		if(iIndexOf != -1)
			strMonths = strTemp.substring(0,iIndexOf);
 	}
	
	if (WI.fillTextValue("save_record").equals("1")) {
		vRetResult = rptExtn.operateOnFlexiOneTimeIn(dbOP, 1);
		if (vRetResult == null)
			strErrMsg = rptExtn.getErrMsg();
	}
	
	if (WI.fillTextValue("viewRecords").equals("1")) {
		vRetResult = rptExtn.operateOnFlexiOneTimeIn(dbOP, 4);
		if (vRetResult == null) 
			strErrMsg = rptExtn.getErrMsg();
		else 
			iSearchResult = rptExtn.getSearchCount();	
	}
	
	String strSchCode = dbOP.getSchoolIndex();
	String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
	
	String strCurDate = null;
	
	vLateSetting = allowedLateTIN.operateOnLateSetting(dbOP, request, 3);
%>
<form action="./emp_flexi_one_timein.jsp" name="dtr_op" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        SUMMARY OF EMPLOYEE WITH SINGLE TIME IN ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" ><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font color=\"#FF0000\" size=\"3\"><strong>","</strong></font>","")%></strong></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date &nbsp;&nbsp;&nbsp;&nbsp;:: 
        &nbsp;From: 
        <input name="date_fr" type="text" size="12" readonly="true"  class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_fr")%>">
          <a href="javascript:show_calendar('dtr_op.date_fr');" title="Click to select date" 
		  onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		  <img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To : 
          <input name="date_to" type="text"  size="12" readonly="true" class="textbox" 
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>">
          <a href="javascript:show_calendar('dtr_op.date_to');" title="Click to select date" 
		  onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		  <img src="../../../images/calendar_new.gif" border="0"></a>
		</td>
  </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="26">&nbsp; </td>
      <td height="25" colspan="2"> Month and Year</td>
      <td width="590" height="25">
			<select name="month_of">
      <option value="">&nbsp;</option>
			<%
	  int iDefMonth = Integer.parseInt(WI.getStrValue(strMonths,"0"));
	  	for (i = 1; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
      <option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
      <%} // end for lop%>
     </select>
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25" colspan="2">Employee ID</td>
      <td height="25"><select name="id_number_con">
          <%=rptExtn.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select><input name="emp_id" type="text" size="12" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>"></td>
    </tr>
		 <%if(strSchCode.startsWith("AUF")){%>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25" colspan="2">Employment Category </td>
      <td height="25"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				strTemp = WI.fillTextValue("emp_type_catg");
				for(i = 0;i < astrCategory.length;i++){
					if(strTemp.equals(Integer.toString(i))) {%>
        <option value="<%=i%>" selected><%=astrCategory[i]%></option>
        <%}else{%>
        <option value="<%=i%>"> <%=astrCategory[i]%></option>
        <%}
							}%>
      </select></td>
    </tr>
		<%}%>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp; </td>
      <td height="25" colspan="2">Position</td>
      <td height="25"><strong> 
        <%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
					WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
					" order by EMP_TYPE_NAME asc", strTemp2, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="24" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="24"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
		strTemp = WI.fillTextValue("c_index");
		if (strTemp.length()<1) strTemp="0";
	   if(strTemp.compareTo("0") ==0)
		   strTemp2 = "Offices";
	   else
		   strTemp2 = "Department";
	%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25" colspan="2"><%=strTemp2%></td>
      <td height="25"> <select name="d_index">
          <% if(strTemp.compareTo("") ==0){//only if from non college.%>
          <option value="">All</option>
          <%}else{%>
          <option value="">All</option>
          <%} strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td colspan="3" class="fontsize11"><strong>SORT BY</strong></td>
    </tr>
    
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td width="26%"><select name="sort_by1">
        <option value="">N/A</option>
        <%=rptExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td width="64%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=rptExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td height="25"><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
	if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td width="5%">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><input type="button" value=" Proceed " name="proceed" onClick="javascript:ViewRecords();" style="font-size:11px; height:28px;border: 1px solid #FF0000;"> </td>
    </tr>
  </table>
<%
	iPageCount = iSearchResult/rptExtn.defSearchSize;
	if(iSearchResult % rptExtn.defSearchSize > 0) ++iPageCount;	
	if (iPageCount > 1){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="40%">&nbsp;</td>
			<td width="60%" align="right">&nbsp;
        <% if (!WI.fillTextValue("show_all").equals("1")) {%>
			Jump To page:
			<select name="jumpto" onChange="ViewRecords();">
				<%
				strTemp = request.getParameter("jumpto");
				if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
				for(i =1; i<= iPageCount; ++i){
				if(i == Integer.parseInt(strTemp)){%>
				<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}
				} // end for loop%>
			</select>
			<%}%>
			</td>
		</tr>
	</table>
	<%}%>
	<%if (vRetResult !=null && vRetResult.size()> 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="right">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="10%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
        NAME </font></strong></td>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
      <td width="16%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">TIME IN </font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">TIME OUT </font></strong></td>
      <td width="4%" align="center" class="thinborder"><font size="1"><strong>ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <% 
		int iCount = 1;
		for(i = 0; i < vRetResult.size(); i +=20, iCount++){
		if(strCurDate == null || !((String)vRetResult.elementAt(i + 11)).equals(strCurDate)){
			strCurDate = (String)vRetResult.elementAt(i + 11);
		%>
		<tr>
      <td height="25" colspan="7" class="thinborder"><strong>DATE : <%=strCurDate%></strong></td>
    </tr>
		<%}%>
		<input type="hidden" name="tin_tout_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i + 12)%>">
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%> </td>
      <td class="thinborder">&nbsp; 
	  <% 
	  	strTemp = "";
	  	if(vRetResult.elementAt(i + 7) != null) {
	  		if(vRetResult.elementAt(i + 8) != null) {
				strTemp = (String)vRetResult.elementAt(i + 7) + " / "  + (String)vRetResult.elementAt(i + 8);
			}else{
				strTemp = (String)vRetResult.elementAt(i + 7);
			}//end of inner loop/
	     }else 
	 		if(vRetResult.elementAt(i + 8) != null){ 
				strTemp = (String)vRetResult.elementAt(i + 8);
			}
	  %><%=strTemp%>      </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
			<%
				lTime = ((Long)vRetResult.elementAt(i + 9)).longValue();
				if(lTime > 0){
					strTemp = WI.formatDateTime(lTime, 2);
				} else {
					strTemp = "";
				}
			%>
			<input type="hidden" name="time_in_<%=iCount%>" value="<%=lTime%>">
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				lTime = ((Long)vRetResult.elementAt(i + 10)).longValue();

				if(lTime > 0)
					strTemp = WI.formatDateTime(lTime, 2);				
				else
					strTemp = "";
			%>
			<input type="hidden" name="time_out_<%=iCount%>" value="<%=lTime%>">
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
      <td align="right" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" checked>&nbsp;</td>
    </tr>
    <%}//end of for loop to display employee information.%>
		 <input type="hidden" name="recordcount" value="<%=iCount%>">
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
     <tr> 
      <td height="25" >Note: Please check carefully.</td>
    </tr>
     <tr>
			<%
				if(vLateSetting != null && vLateSetting.size() > 0)
					strTemp = (String)vLateSetting.elementAt(14);
				else
					strTemp = WI.fillTextValue("break_remove");
				strTemp = WI.getStrValue(strTemp);
			%>
       <td height="25" align="center" ><input name="break_remove" type="text" size="4" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>">
       <u><strong>break duration (in minutes) </strong></u></td>
     </tr>
     <tr>
       <td height="18" >&nbsp;</td>
     </tr>
     <tr>
       <td height="25" ><center>
         <font size="1">
           <input type="button" name="122" value=" Continue " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
          click to remove break from the total hours worked </font>
       </center>       </td>
     </tr>
  </table>
  <%}// end vRetResult !=null && vRetResult.size%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
   <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type=hidden name="viewRecords" value="0">
	<input type=hidden name="save_record">
  <input type="hidden" name="show_only_total" value="1">
  <input type="hidden" name="print_pg">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>