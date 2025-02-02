<%@ page language="java" import="utility.*,java.util.Vector,hr.HRApplPersonalExtn"%>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Applicant's Data Card</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size:11px;
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
</head><script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function Convert() {
	var pgLoc = 
	"../../../commfile/conversion.jsp?called_fr_form=appl_profile&cm_field_name=height&lb_field_name=weight";
	
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewInfo(){
	document.appl_profile.page_action.value = "3";
}

function AddRecord(){
	document.appl_profile.page_action.value="1";
	document.appl_profile.hide_save.src = "../../../images/blank.gif";
	document.appl_profile.submit();
}

function EditRecord(){

	document.appl_profile.page_action.value="2";
	document.appl_profile.submit();
}


function viewList(table,indexname,colname,labelname){ 
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
	"&opner_form_name=appl_profile";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}

function OpenSearch() {
	var pgLoc = "./applicant_search_name.jsp?opner_info=appl_profile.appl_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function CancelRecord(strEmpID){
	location = "./hr_applicant_personal.jsp";
}
function FocusID() {
	document.appl_profile.appl_id.focus();
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-APPLICANTS DIRECTORY-Personal Data","hr_applicant_personal.jsp");
		
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
		
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(), 
														"hr_applicant_personal.jsp");	
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
Vector vApplicantInfo  = null;
boolean bolNoRecord = true;
String strInfoIndex = WI.fillTextValue("info_index");

HRApplPersonalExtn hrApplPersonal = new HRApplPersonalExtn();
hr.HRApplNew hrApplNew = new hr.HRApplNew();

strTemp = WI.fillTextValue("appl_id");
if(strTemp.length() > 0){
	vApplicantInfo = hrApplNew.operateOnApplication(dbOP, request,3);//view one.
	if(vApplicantInfo == null)
		strErrMsg = hrApplNew.getErrMsg();
}

boolean bolClearEntries = false;

if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here. 
	int iAction =  3;
	iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
	if (iAction == 1 || iAction  == 2 || iAction==3)
	vRetResult = hrApplPersonal.operateOnPersonalData(dbOP,request,iAction);

	if (iAction == 3 &&  hrApplPersonal.getErrMsg() == null){
		bolClearEntries = true;
	}

	switch(iAction){
		case 1:{ // add Record
			if (vRetResult != null)
				strErrMsg = " Applicant personal record added successfully.";
			else
				strErrMsg = hrApplPersonal.getErrMsg();
			break;
		}
		case 2:{ //  edit record
			if (vRetResult != null)
				strErrMsg = " Applicant personal record edited successfully.";
			else
				strErrMsg = hrApplPersonal.getErrMsg();
			break;
		}
		case 3:{ //  view record
			if (vRetResult == null)
				strErrMsg = hrApplPersonal.getErrMsg();
			break;
		}
	} //end switch

}

if (vRetResult != null && vRetResult.size() >0){
	strInfoIndex = (String)vRetResult.elementAt(18);
	bolNoRecord = false;	
}

if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

%>


<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_applicant_personal.jsp" method="post" name="appl_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PERSONAL DATA PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr > 
      <td width="17%" height="28"><div align="right"><font size="1"><strong>&nbsp;&nbsp;</strong></font>Applicant's 
          ID :&nbsp;&nbsp;</div></td>
      <td width="18%"><input type="text" name="appl_id" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=strTemp%>"> 
      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
      </td>
      <td width="60%"><input name="image" type="image" onClick="viewInfo();" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
<%
if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here. %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"> 
        <table width="526" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.fillTextValue("appl_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vApplicantInfo.elementAt(1),(String)vApplicantInfo.elementAt(2),
						 				 (String)vApplicantInfo.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vApplicantInfo.elementAt(11))%><br> 
              <%=WI.getStrValue(vApplicantInfo.elementAt(5),"<br>","")%> 
              <!-- email -->
              <%=WI.getStrValue(vApplicantInfo.elementAt(4))%> 
              <!-- contact number. -->
            </td>
          </tr>
        </table></td>
      <td width="17%" rowspan="8"><img src="../../../images/sidebar.gif" width="11" height="270" align="right"></td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%">Gender</td>
      <td width="63%"> 
 <% if(vRetResult != null && vRetResult.size() > 0)
		strTemp = (String)vRetResult.elementAt(0);
	else 
		if (bolClearEntries) 
			strTemp = "";
		else
			strTemp = WI.fillTextValue("gender");
%>
        <select name="gender">
          <option value="0">Male</option>
          <% if(strTemp.equals("1")) {%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Civil Status</td>
      <td> 
        <%
			if(vRetResult != null && vRetResult.size() > 0)
				strTemp = (String)vRetResult.elementAt(1);
			else 
				if (bolClearEntries) 
					strTemp = "";
				else
					strTemp = WI.fillTextValue("cstatus");
			
			%>
         <select name="cstatus">
          <option value="0">Single</option>
          <% if (strTemp.equals("1")) {%>
          <option value="1" selected>Married</option>
          <%}else{%>
          <option value="1">Married</option>
          <%} if (strTemp.equals("2")) {%>
          <option value="2" selected>Divorced/Separated</option>
          <%}else{%>
          <option value="2" >Divorced/Separated</option>
          <%} if (strTemp.equals("3")) {%>
          <option value="3" selected>Widow/Widower</option>
          <%}else{%>
          <option value="3" >Widow/Widower</option>
          <%}
		if(bolAUF){
		  if (strTemp.equals("4")) {%>
          <option value="4" selected>Annuled</option>
          <%}else{%>
          <option value="4">Annuled</option>
          <%} if (strTemp.equals("5")) {%>
          <option value="5" selected>Living Together</option>
          <%}else{%>
          <option value="5" >Living Together</option>
          <%}
		}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Spouse (if Married)</td>
      <td> 
        <%
				if(vRetResult != null && vRetResult.size() > 0)
					strTemp = WI.getStrValue(vRetResult.elementAt(2));
				else 
					if (bolClearEntries)
						strTemp = "";
					else
						strTemp = WI.fillTextValue("spouse");				
				%>
        <input name="spouse" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'"  size="48" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Nationality</td>
      <td> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(3);
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("nationality");

%>
        <select name="nationality">
          <option value="">Select nationality</option>
          <%=dbOP.loadCombo("NATIONALITY_INDEX","NATIONALITY"," FROM HR_PRELOAD_NATIONALITY",strTemp,false)%> 
        </select> 
<%if(iAccessLevel > 1){%>
		<a href='javascript:viewList("HR_PRELOAD_NATIONALITY","NATIONALITY_INDEX","NATIONALITY","NATIONALITY")'><img  border="0" src="../../../images/update.gif"></a> 
        <font size="1">click to add/edit list of nationality</font>
<%}%>
		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Religion</td>
      <td> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(4);
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("religion");

%>
        <select name="religion">
          <option value="">Select Religion</option>
          <%=dbOP.loadCombo("RELIGION_INDEX","RELIGION"," FROM HR_PRELOAD_RELIGION",strTemp,false)%> 
        </select> 
<%if(iAccessLevel > 1){%>
		<a href='javascript:viewList("HR_PRELOAD_RELIGION","RELIGION_INDEX","RELIGION","RELIGION")'><img border="0" src="../../../images/update.gif"></a> 
        <font size="1">click to add/edit list of religion</font>
<%}%>
		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Date of Birth</td>
      <td> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(5);
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("dob");

%>
       <input name="dob" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
		onblur="style.backgroundColor='white'; AllonOnlyIntegerExtn('appl_profile','dob')" 
		size="12" onKeyUp="AllonOnlyIntegerExtn('appl_profile','dob')"  
		value="<%=WI.getStrValue(strTemp)%>"> 
        <a href="javascript:show_calendar('appl_profile.dob');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Place of Birth</td>
      <td> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(6));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("pob");

%>
        <input name="pob" value="<%=strTemp%>" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
						onblur="style.backgroundColor='white'" size="48"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Height (in cm)</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(7);
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("height");

%>
        <input name="height" type= "text" value="<%=WI.getStrValue(strTemp)%>" onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="height" size="8">
        <font size="1">(1ft = 30.48cms)<a href="javascript:Convert();"> CLICK 
        FOR CONVERSION</a></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Weight (in lbs)</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(8);
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("weight");

%>
        <input name="weight" type= "text" value="<%=WI.getStrValue(strTemp)%>" onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="weight" size="8"> 
        <font size="1">(1kg = 2.2lbs)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SSS</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(9));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("sss");

%>
        <input name="sss" type= "text" value="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="sss" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>TIN</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(10));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("tin");
%>
        <input name="tin" type= "text" class="textbox"  value="<%=strTemp%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Father's Name</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(11));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("father");

%>
        <input name="father" type= "text" value ="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="father" size="32"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Occupation</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(12));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("f_occ");

%>
        <input name="f_occ" type= "text" value ="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="f_occ" size="40"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Mother's Name</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(13));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("mother");
%>
        <input name="mother" type= "text" value ="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="mother" size="32"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Occupation</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(14));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("m_occ");
%>
        <input name="m_occ" type= "text" value="<%=strTemp%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="m_occ" size="40"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>REGION</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = (String)vRetResult.elementAt(15);
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("region");

%>
        <select name="region">
          <option value="">Select Region</option>
          <%=dbOP.loadCombo("REGION_INDEX","REGION"," FROM HR_PRELOAD_REGION",strTemp,false)%> 
        </select>
<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("HR_PRELOAD_REGION","REGION_INDEX","REGION","REGION")'><img border="0" src="../../../images/update.gif"></a> 
        <font size="1"><em>(CREATE A REGION TO LOCATE THE NEAREST APPLICANTS)</em></font>
<%}%>
		</td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1" color="blue"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td> Mailing Address</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(16));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("caddress");

%>
        <textarea name="caddress" cols="50" rows="2" id="caddress" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea> 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td> Home Address</td>
      <td colspan="2"> 
        <%
if(vRetResult != null && vRetResult.size() > 0)
	strTemp = WI.getStrValue(vRetResult.elementAt(17));
else 
	if (bolClearEntries)
		strTemp ="";
	else
		strTemp = WI.fillTextValue("home_address");
%>
        <textarea name="home_address" cols="50" rows="2" id="textarea2" class="textbox" 
				onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td colspan="4" align="center" height="25"> 
        <% if (iAccessLevel > 1){
	if(bolNoRecord) {%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save entries&nbsp; 
        <%}else{%>
        <a href='javascript:CancelRecord();'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel and clear entries</font></font> <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> 
        <%}
		}//iAccessLevel > 1%>
      </td>
    </tr>
  </table>
 <%}//only if Applicant info is not null
 %> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" value="<%=strInfoIndex%>" name="info_index">
<input type="hidden" name="page_action">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>