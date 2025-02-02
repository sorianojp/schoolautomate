<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	String strSchCode = 
			WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
			
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript">

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	this.SubmitOnce("form_");
}

function ReloadPage(){
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value="2";
	this.SubmitOnce("form_");
}

function DeleteRecord(index){
	document.form_.page_action.value="0";
	document.form_.info_index.value= index;
	this.SubmitOnce("form_");	
}
//pass extra con is null, so that, it can't be deleted.. this table is linking to employee training as well.. 
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, 
					strExtraTableCond,strExtraCond,strFormField,strHideDel){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond) + 
	"&extra_cond="+escape(strExtraCond) +"&hide_del="+strHideDel+
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function CancelRecord(){
	location ="./mandatory_trainings.jsp";
}


</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Request Training","set_mandatory_training.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
												"HR Management","TRAINING MANAGEMENT",request.getRemoteAddr(),
												"mandatory_training.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vEditInfo = null;
String strPrepareToEdit = null;
hr.HRMandatoryTrng  mt = new hr.HRMandatoryTrng();

int iAction =  Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (iAction == 0){
	if (mt.operateOnMandTrainingList(dbOP, request,0) != null){
		strErrMsg= " Training name removed successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}else if ( iAction == 1){
	if (mt.operateOnMandTrainingList(dbOP, request,1) != null){
		strErrMsg= " Training name recorded successfully";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}else if ( iAction == 2){
	if (mt.operateOnMandTrainingList(dbOP, request,2) != null){
		strErrMsg= " Training name updated successfully";
		strPrepareToEdit = "";
	}else{
		strErrMsg = mt.getErrMsg();
	}
}

if (strPrepareToEdit.equals("1")){
	vEditInfo = mt.operateOnMandTrainingList(dbOP, request,3);
	if (vEditInfo == null) 
		strErrMsg = mt.getErrMsg();
}

if (!WI.fillTextValue("view_5").equals("1")) {
	//System.out.println(" I am here.");
	vRetResult = mt.operateOnMandTrainingList(dbOP, request,4);
}else{
	vRetResult = mt.operateOnMandTrainingList(dbOP, request,5);
	if (vRetResult == null) 
		strErrMsg = mt.getErrMsg();
}

%>
<body bgcolor="#663300"  class="bgDynamic">
<form action="./mandatory_trainings.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::  MANDATORY TRAININGS FOR PERSONNEL ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<% if (!WI.fillTextValue("view_5").equals("1")){%>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="19%" height="30">TYPE OF TRAINING </td>
<%	if (vEditInfo != null) 
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
	else strTemp = WI.fillTextValue("training_type_index");
%>	  <td width="28%" height="30">
        <select name="training_type_index" >
          <option value="">Select Training Type</option>
          <%=dbOP.loadCombo("TRAINING_TYPE_INDEX","TRAINING_TYPE"," FROM HR_PRELOAD_TRAINING_TYPE order by TRAINING_TYPE",strTemp,false)%>
        </select></td>
    <td width="49%">
		<a href='javascript:viewList("HR_PRELOAD_TRAINING_TYPE","TRAINING_TYPE_INDEX",
			"TRAINING_TYPE","TYPE OF TRAINING",	"HR_PRELOAD_MAND_TRAINING","TRAINING_TYPE_INDEX", 
			" and HR_PRELOAD_MAND_TRAINING.MAND_TRAINING_INDEX > 0","","training_type_index","1")'><img src="../../../images/update.gif" border="0"></a><font size="1">click to add to types of training </font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

    <tr>
      <td width="4%">&nbsp;</td>
      <td width="96%" height="30" valign="bottom">TRAINING NAME / DESCRIPTION :</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
<% if (vEditInfo != null) 
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = WI.fillTextValue("training_name"); %>
      <td height="23">
  	  <textarea name="training_name" cols="64" rows="3" class="textbox" 
	  	onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="23">&nbsp;</td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" align="center"> 
        <% if (iAccessLevel > 1){
			if (vEditInfo  == null){%>        
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save all entries</font> 
        <%}else{ %>        <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font><a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel and clear entries</font> 
        <%} // end else vEdit Info == null
		  } // end iAccessLevel  > 1%></td>
    </tr>
    <tr>
      <td height="22" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%} // do not show above in case of history view only.. 

 if (vRetResult != null && vRetResult.size() > 0) { %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBEEE0"> 
      <td height="25" colspan="4" align="center" class="thinborder"><strong>LIST 
        OF MANDATORY TRAININGS 
	<% if (WI.fillTextValue("view_5").equals("1")) {%> 
		(OLD DATA)
	<%}%> 
				
		
		</strong></td>
    </tr>
    <tr> 
      <td width="23%" height="25" class="thinborder"><strong>TYPE OF TRAINING </strong></td>
      <td width="63%" class="thinborder"><strong>NAME OF TRAINING DESCRIPTION </strong></td>
      <td width="6%" class="thinborder"><strong>EDIT</strong></td>
      <td width="8%" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% 
		String strCurrTypeIndex = "";
		for (int i=0 ; i < vRetResult.size(); i+=4){
		strTemp = "";
		if (!strCurrTypeIndex.equals((String)vRetResult.elementAt(i+1))){
			strTemp = (String)vRetResult.elementAt(i+3);
			strCurrTypeIndex = (String)vRetResult.elementAt(i+1);
		}
	%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp;")%></td>
      <td class="thinborder">
<%  if (iAccessLevel > 1 && !WI.fillTextValue("view_5").equals("1")){%>
	  <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
<%}else{%> N/A <%}%>	  
      </td>
      <td class="thinborder"> 
<%  if ( iAccessLevel == 2) {%> 
		<a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%> NA <%}%> </td>
    </tr>
    <%}%>
  </table>
<% } //vRetResult != null && vRetResult.size() > 0%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="4" align="center" class="thinborder">
	  <% if (WI.fillTextValue("view_5").equals("1")) 
	  		 strTemp = "checked";
		else
			strTemp = ""; %>
	  
        <input type="checkbox" name="view_5" value="1" onClick="ReloadPage()" <%=strTemp%>>
		<strong><font size="1">click to view history </font></strong>
      </td>
    </tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>  
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

