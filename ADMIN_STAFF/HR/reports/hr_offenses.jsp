<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11 {
		font-size:11px;
	}

	a {
	text-decoration: none;
	}
</style>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");	
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function EditRecord(strEmpID){
	var pgLoc = "../personnel/hr_personnel_offenses.jsp?emp_id=" + escape(strEmpID);
	var win=window.open(pgLoc,"EditWindow",'width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

 
</script>

<body bgcolor="#663300"  class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iSearchResult = 0;
	boolean bolHasConfidential = false;	
	boolean bolHasTeam = false;	
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_offenses_print.jsp" />
<%	return;}	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Education","hr_offenses.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_offenses.jsp");
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
Vector vRetResult = null;

HRStatsReports hrStat = new HRStatsReports(request);
String strPrevUser = "";
boolean bolSameUser = false;

if ( WI.fillTextValue("show_list").equals("1")){
	vRetResult = hrStat.getEmployeeOffenses(dbOP, true);
	if(vRetResult == null)
		strErrMsg = hrStat.getErrMsg();
	else	
		iSearchResult = hrStat.getSearchCount();
}

//System.out.println(vRetResult);

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";	
String[] astrSortByName    = {"ID number", strTemp, "Department", "Date of Offense"};
String[] astrSortByVal     = {"id_number","c_name","d_name", "offense_date"};
%>
<form action="./hr_offenses.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          EMPLOYEE OFFENSES REPORT ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Employee ID</td>
      <td colspan="3"><select name="emp_id_con" >
          <%=hrStat.constructSortByDropList(WI.fillTextValue("emp_id_con"),astrDropListEqual,astrDropListValEqual)%> </select> <input name="emp_id" type="text" value="<%=WI.fillTextValue("emp_id")%>" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          &nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%" class="fontsize11">Name of Offense </td>
      <td colspan="3"> <select name="offense_name_index">
                <option value="">Any Offense</option>
          <%=dbOP.loadCombo("OFFENSE_NAME_INDEX","OFFENSE_NAME"," FROM HR_PRELOAD_OFFENSE order by offense_name",WI.fillTextValue("offense_name_index"),false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date of Offense</td>
      <td width="16%"><input name="date_offense" type="text"  class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeyUp="AllowOnlyIntegerExtn('form_','date_offense','/')"
		  value="<%=WI.fillTextValue("date_offense")%>" size="10" maxlength="10"> 
      &nbsp;<a href="javascript:show_calendar('form_.date_offense');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td width="4%" align="right" class="fontsize11">To&nbsp;&nbsp;</td>
      <td width="61%"><input name="date_offense_to" type="text"  class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	onKeyUp="AllowOnlyIntegerExtn('form_','date_offense_to','/')"
		  value="<%=WI.fillTextValue("date_offense_to")%>" size="10" maxlength="10">
&nbsp;<a href="javascript:show_calendar('form_.date_offense_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Action Taken </td>
      <td colspan="3"><select name="action_index">
                <option value="">Any</option>
          <%=dbOP.loadCombo("action_index","ACTION_NAME"," FROM HR_PRELOAD_OFFENSE_ACTION "+ 
				"  order by action_index",WI.fillTextValue("action_index"),false)%> </select>
              </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <%}if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Position</td>
      <td colspan="3"><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
    </tr>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>		
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>
        College
          <%}else{%>
          Division
      <%}%></td>
      <td colspan="3"><select name="c_index" onChange="loadDept();">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Department/Office</td>
      <td colspan="3">
			<label id="load_dept">
			<select name="d_index">
        <option value="">ALL</option>
        <%if (strCollegeIndex.length() == 0){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%>
        <%}else if (strCollegeIndex.length() > 0){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
        <%}%>
      </select>
			</label>
			</td>
    </tr>
		<%if(bolHasConfidential){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Process Option</td>
			<%String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";		
			%>
			
      <td colspan="3"><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>
		<%if(bolHasTeam){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Team</td>
      <td colspan="3"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
		<%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">&nbsp;<span class="fontsize11">Sort by</span></td>
      <td width="27%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="27%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="32%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="40" colspan="2">&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% 
	int iChkBox = 0;
	if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 

      <td height="25">
<% if (WI.fillTextValue("show_all").length() > 0) strTemp = "checked";
else strTemp ="";%>	  
	  <input type="checkbox" name="show_all" value="1" <%=strTemp%>>Check to show all </td>

      <td height="25" align="right">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">SEARCH 
        RESULT</font></strong></td>
    </tr>
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> 
  	    <% if (WI.fillTextValue("show_all").length() ==0 ) {%>
			 - Showing(<%=hrStat.getDisplayRange()%>)
        <%}%>
			 </b></td>
      <td width="51%">        <%
		if (WI.fillTextValue("show_all").length() == 0){
		
			int iPageCount = iSearchResult/hrStat.defSearchSize;
			if(iSearchResult % hrStat.defSearchSize > 0) ++iPageCount;

			if(iPageCount > 1)
			{%>
    	    <div align="right">Jump To page: 
	          <select name="jumpto" onChange="showList();">
	            <%
				strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select></div>
          <%}
		  }// end if (WI.fillTextValue("show_all")%>
</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="22%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
			<td width="15%" align="center"  class="thinborder"><strong><font size="1">OFFICE/DEPT</font></strong></td>
      <td width="11%"  class="thinborder"><strong><font size="1">&nbsp;DATE OF OFFENSE </font></strong></td>
      <td width="34%" align="center"  class="thinborder"><strong><font size="1">NAME OF OFFENSE / DETAIL </font></strong></td>
      <td width="18%" align="center"  class="thinborder"><font size="1"><strong>ACTION TAKEN / EFFECTIVE DATE(S)</strong></font></td>
    </tr>
    <% 
		for (int i=0; i < vRetResult.size(); i+=25){
			bolSameUser = false;
			if(strPrevUser.equals((String)vRetResult.elementAt(i+15)))
				bolSameUser = true;
		
	%>
    <tr>
			<%
				if(bolSameUser)
					strTemp = "";
				else
					strTemp = WI.formatName((String)vRetResult.elementAt(i+2),
  									(String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4),4);
			%>
      <td class="thinborder">&nbsp;
	  		<a href="javascript:EditRecord('<%=(String)vRetResult.elementAt(i+1)%>')"> 
					<%=strTemp%> </a>	  </td>
			<%
				if(bolSameUser)
					strTemp = "";
				else{
					if((String)vRetResult.elementAt(i + 13)== null || (String)vRetResult.elementAt(i + 14)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}					
					
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 13),"") + strTemp +
										WI.getStrValue((String)vRetResult.elementAt(i + 14),"");
				}
			%>			
      <td class="thinborder">&nbsp;<%=strTemp%></td>					
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7))%></td>
      <td class="thinborder"><strong>Offense</strong> :<%=(String)vRetResult.elementAt(i+5)%> <br>
        <strong>Detail</strong> :<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "n/a")%> </td>
	<% 
		if ((String)vRetResult.elementAt(i+9) != null) {
			strTemp = "<br>(" + (String)vRetResult.elementAt(i+9);
			strTemp +=  ((String)vRetResult.elementAt(i+10) != null)?
					" - " +  (String)vRetResult.elementAt(i+10) + ")": ")";

		}else strTemp = ""; %>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i+8))  + strTemp%> </td>
    </tr>
    <%
			strPrevUser = (String)vRetResult.elementAt(i+15);
		}// end for loop %>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18">&nbsp;&nbsp;<font size='1'>Note : Click on the employee name to view all the recorded offenses of the employee  </font></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr>
			<%
				strTemp = WI.fillTextValue("title_report");
				if(strTemp.length() == 0)
					strTemp = "Employee Offenses";
			%>
      <td height="25">&nbsp;Title of the Report: 
        <input name="title_report" type="text" class="textbox" size="48"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>

    <tr> 
      <td height="25"><div align="center"><font size="2">Number of offenses Per 
        Page :</font><font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
         </font><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="max_value" value="<%=iChkBox%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>